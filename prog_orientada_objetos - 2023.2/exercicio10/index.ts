// as vizualizacoes nao estao decrementando 
// postagensPopulares
// excluirPostagem
// consultar por hashtag 
// consultar por perfil
// curtir e descurtir

import { AplicacaoError, AtributoVazioError, PerfilExistenteError, PerfilNaoEncontradoError, PostagemJaExisteError, PostagemNaoEncontradaError } from "./excecoes";
import * as fs from 'fs';

class Perfil{
    private _idPerfil: number;
    private _nome: string;
    private _email: string;
    private _postagensDoPerfil: Postagem[] = [];
    constructor(i:number, n:string, e:string){
        this._idPerfil = i;
        this._nome = n;
        this._email = e;
    }

    get idPerfil(): number{
        return this._idPerfil;
    }

    get nome(): string{
        return this._nome;
    }

    get email(): string{
        return this._email;
    }

    get postagensDoPerfil(): Postagem[] {
        return this._postagensDoPerfil;
    }

    set nome(nome: string){
        this._nome = nome
    }

    set email(email: string){
        this._email = email;
    }

    set idPerfil(id: number){
        this._idPerfil = id;
    }
}

class Postagem{
    private _idPostagem: number;
    private _texto: string;
    private _curtidas: number;
    private _descurtidas: number;
    private _data: Date = new Date();
    private _perfil: Perfil;
    constructor(i:number, t:string, p:Perfil, c: number, d: number){
        this._idPostagem = i;
        this._texto = t;
        this._perfil = p;
        this._curtidas = c;
        this._descurtidas = d
    }

    get idPostagem(): number{
        return this._idPostagem;
    }

    get texto(): string{
        return this._texto;
    }

    get curtidas(): number{
        return this._curtidas
    }

    get descurtidas(): number{
        return this._descurtidas
    }

    get data(): Date{
        return this._data
    }

    get perfil(): Perfil{
        return this._perfil;
    }

    set idPostagem(id: number){
        this._idPostagem = id;
    }

    curtir(): void{
        this._curtidas += 1;
    }

    descurtir(): void{
        this._descurtidas ++;
    }

    ehPopular(): boolean{
        return this.curtidas > (this.descurtidas + this.descurtidas * (50/100));
    }
}

class PostagemAvancada extends Postagem{
    private _hashtags: string[] = [];
    private _visualizacoesRestantes: number = 1;
    constructor(i:number, t:string, p:Perfil, c: number, d: number){
        super(i, t, p, c, d);
    }

    get hashtags(): string[] {
        return this._hashtags;
    }

    get visualizacoesRestantes(): number {
        return this._visualizacoesRestantes;
    }

    set visualizacoesRestantes(v: number){
        this._visualizacoesRestantes = v
    }

    adicionarHashtag(hashtag:string): void{
        this.hashtags.push(hashtag);
    }

    existeHashtag(hashtag:string): boolean {
        let temHashtag = false;
        for(let h of this._hashtags){
            if(h == hashtag){
                temHashtag = true;
                break;
            }
        }
        return temHashtag;
    }

    decrementarVisualizacoes(): void { 
        if (this._visualizacoesRestantes > 0) {
            this._visualizacoesRestantes--;
        }
    }

    quantidadeDeVizualizaoes(): number{
        return 1000 - this.visualizacoesRestantes;
    }
}

interface IRepositorioDePerfis {
    get perfis(): Perfil[]; //adicionei
    incluirPerfil(perfil: Perfil): void;
    consultarPerfil(id?: number, nome?: string, email?: string): Perfil;
    atualizarPerfil(perfil: Perfil):void;
}

interface IRepositorioPostagens {
    get postagens(): Postagem[]; //adicionei
    consultarPorIndice(idPostagem: number): number;
    consultarPostagem(id?: number, texto?: string, hashtag?: string, perfil?: Perfil): Postagem[];
    consultarPostagemPorId(idPost: number): Postagem;
    incluirPostagem(postagem: Postagem): void;
    atualizarPostagem(postagem: Postagem):void;
}

class RepositorioDePerfisArquivo implements IRepositorioDePerfis {
    private arquivo: string;

    constructor(arquivo: string) {
        this.arquivo = arquivo;
    }

    get perfis(): Perfil[] {
        const dados = this.lerArquivo();
        return dados.map((d: any) => new Perfil(d._idPerfil, d._nome, d._email));
    }

    incluirPerfil(perfil: Perfil): void {
        if (perfil.nome && perfil.email) {
            const dados = this.lerArquivo();
            const perfilExiste = this.perfis.find(p => //!alterei perfis
                (p.idPerfil === perfil.idPerfil) ||
                (p.nome === perfil.nome) ||
                (p.email === perfil.email))
                    
            if (perfilExiste) {
                throw new PerfilExistenteError('O perfil já existe');
            }
            perfil.idPerfil = dados.length + 1;  // Atualiza o ID do perfil
            dados.push(perfil);
            this.salvarArquivo(dados);
            

        } else {
            throw new AtributoVazioError('Os atributos precisam ser preenchidos!');
        }
    }
    
    consultarPerfil(id?: number, nome?: string, email?: string):Perfil {
        const dados = this.lerArquivo();

        const perfilEncontrado = dados.find((d: any) => {
            return (
                (id !== undefined && d._idPerfil === id) ||
                (nome !== undefined && d._nome === nome) ||
                (email !== undefined && d._email === email)
            );
        });

        if (!perfilEncontrado) {
            throw new PerfilNaoEncontradoError('Perfil não encontrado!');
        }
        return new Perfil(perfilEncontrado._idPerfil, perfilEncontrado._nome, perfilEncontrado._email);
    }

    private lerArquivo(): any[] {
        try {
            const conteudo = fs.readFileSync(this.arquivo, 'utf-8');
            return JSON.parse(conteudo);
        } catch (error) {
            return [];
        }
    }

    private salvarArquivo(dados: any[]): void {
        fs.writeFileSync(this.arquivo, JSON.stringify(dados, null, 2), 'utf-8');
    }

    atualizarPerfil(perfil: Perfil):void{ //para atualizar os dados dos arquivos
        let dados = this.lerArquivo();
        let perfilExiste = this.perfis.find(p =>(p.idPerfil === perfil.idPerfil));
        if (!perfilExiste) {
            throw new PerfilExistenteError('O perfil já existe');
        }

        let index = this.perfis.findIndex(p => p.idPerfil == perfil.idPerfil);
        if (index != -1) {
            this.perfis[index] = perfil;
            dados[index] = perfil;
            this.salvarArquivo(dados);
        }
    }
}

class RepositorioDePostagensArquivo implements IRepositorioPostagens {
    private arquivo: string;

    constructor(arquivo: string) {
        this.arquivo = arquivo;
    }

    private lerArquivo(): any[] {
        try {
            let conteudo = fs.readFileSync(this.arquivo, 'utf-8');
            return JSON.parse(conteudo);
        } catch (error) {
            return [];
        }
    }

    private salvarArquivo(dados: any[]): void {
        fs.writeFileSync(this.arquivo, JSON.stringify(dados, null, 2), 'utf-8');
    }

    get postagens(): Postagem[] {
        return this.lerArquivo();
    }

    consultarPostagem(id?: number, texto?: string, hashtag?: string, perfil?: Perfil): Postagem[] {
        let dados = this.lerArquivo();
        const postagensFiltradas = dados
            .filter((d: any) => {
                return (
                    (id === undefined || d._idPostagem === id) &&
                    (texto === undefined || d._texto.includes(texto)) &&
                    (perfil === undefined || d._perfil === perfil) &&
                    (hashtag === undefined || (d._hashtags && d._hashtags.includes(hashtag)))
                );
            });

        if (postagensFiltradas.length === 0) {
            throw new PostagemNaoEncontradaError('Postagem não encontrada');
        }

        return postagensFiltradas.map((d: any) => d);
    }

    incluirPostagem(postagem: Postagem): void {
        const dados = this.lerArquivo();
    
        if (postagem.texto.trim() && postagem.perfil) {
            postagem.idPostagem = dados.length + 1;  // Atualiza o ID da postagem
            dados.push(postagem);
            this.salvarArquivo(dados);
        } else {
            throw new AtributoVazioError('Todos os atributos da postagem devem estar preenchidos!');
        }
    }    

    consultarPorIndice(idPostagem: number): number {
        const dados = this.lerArquivo();
        const indice = dados.findIndex((d: any) => d._idPostagem === idPostagem);

        if(indice == -1){
            throw new PostagemNaoEncontradaError('Postagem não encontrada');
        }
        
        return indice;
    }

    consultarPostagemPorId(idPost: number): Postagem {
        const dados = this.lerArquivo();
        const postagemProcurada = dados.find((d: any) => d._idPostagem === idPost);
        
        if(postagemProcurada === undefined){
            throw new PostagemNaoEncontradaError('Postagem não encontrada');
        }
        
        this.salvarArquivo(dados);
        return postagemProcurada;
    } 

    atualizarPostagem(postagem: Postagem):void { // atualizar postagem
        let dados = this.lerArquivo();
        let postagemExiste = this.postagens.find(p => (p.idPostagem == postagem.idPostagem));
        if (!postagemExiste) {
            throw new PerfilNaoEncontradoError('Postagem não encontrada.');
        }
        let index = this.postagens.findIndex(p => p.idPostagem == postagem.idPostagem);
        if (index != -1) {
            this.postagens[index] = postagem;
            dados[index] = postagem;
            this.salvarArquivo(dados);
        }
    }
    
}

class RepositorioDePerfisArray implements IRepositorioDePerfis {
    private _perfis: Perfil[] = [];

    get perfis(): Perfil[] { //adicionei
        return this._perfis;
    }

    consultarPerfil(id?: number, nome?: string, email?: string): Perfil {
        let perfilProcurado!: Perfil;
        try {
            const perfilProcurado0 = this.perfis.find(p =>
                (id === undefined || p.idPerfil === id) &&
                (nome === undefined || p.nome === nome) &&
                (email === undefined || p.email === email)
            );

            if (!perfilProcurado0) {
                throw new PerfilNaoEncontradoError('Perfil não encontrado!');
            }

            perfilProcurado = perfilProcurado0;
        } catch (e: any) {
            if (e instanceof AplicacaoError) {
                console.log(e.message);
            }
        }

        return perfilProcurado;
    }

    incluirPerfil(perfil: Perfil){
        try {
            if (perfil.idPerfil && perfil.nome && perfil.email) {
                const perfilExiste = this.perfis.find(p => //!alterei perfis
                    (p.idPerfil === perfil.idPerfil) ||
                    (p.nome === perfil.nome) ||
                    (p.email === perfil.email)
                );

                if (perfilExiste) {
                    throw new PerfilExistenteError('O perfil já existe');
                }
            } else {
                throw new AtributoVazioError('Os atributos precisam ser preenchidos!');
            }

            this.perfis.push(perfil); //!alterei perfis
            console.log('Perfil incluído com sucesso!');
        } catch (e:any){
                if(e instanceof AplicacaoError){
                    console.log(e.message);
            } 
        }
    } 

    atualizarPerfil(perfil: Perfil): void {// adicionado a interface - ver como implementar esse metodo nesse repositorio
    }
}

class NoPerfil { // armazena Perfil e tem uma referência para o próximo nó na lista.
    perfil: Perfil;
    proximo: NoPerfil | null; // referencia o próximo nó na lista (se for o último nó, é definida como null)

    constructor(perfil: Perfil) {
        this.perfil = perfil;
        this.proximo = null; 
    }
}

class RepositorioDePerfisLista implements IRepositorioDePerfis {
    private inicio: NoPerfil | null; // início da lista encadeada, o primeiro nó. começa como null quando a lista ta vazia

    constructor() {
        this.inicio = null;
    } 

    get perfis(): Perfil[] { //adicionei
        let perfis: Perfil[] = [];
        let atual = this.inicio;

        while (atual !== null) {
            perfis.push(atual.perfil);
            atual = atual.proximo;
        }
        return perfis;
    }

    incluirPerfil(perfil: Perfil): void {
        const novoNo = new NoPerfil(perfil);

        if (this.inicio == null) {
            this.inicio = novoNo;
        } else {
            let atual = this.inicio;
            while (atual.proximo != null) { // percorre até encontrar o ultimo nó 
                atual = atual.proximo;
            }
            atual.proximo = novoNo; // adiciona ao final da lista
        }

    }

    consultarPerfil(id?: number, nome?: string, email?: string): Perfil {
        let atual = this.inicio;

        while (atual != null) {
            if (
                (id != undefined && atual.perfil.idPerfil == id) ||
                (nome != undefined && atual.perfil.nome == nome) ||
                (email != undefined && atual.perfil.email == email)
            ) {
                return atual.perfil;
            }

            atual = atual.proximo;
        }

        throw new PerfilNaoEncontradoError('Perfil não encontrado');
    }
    atualizarPerfil(perfil: Perfil): void { // adicionado a interface - ver como implementar esse metodo nesse repositorio
    }
}

class NoPostagem { // mesma coisa de perfil
    postagem: Postagem;
    proximo: NoPostagem | null;

    constructor(postagem: Postagem) {
        this.postagem = postagem;
        this.proximo = null;
    }
}

class RepositorioDePostagensLista implements IRepositorioPostagens {
    private inicio: NoPostagem | null;

    constructor() {
        this.inicio = null;
    }
    
    get postagens(): Postagem[] { //adicionei
        let postagens: Postagem[] = [];
        let atual = this.inicio;

        while (atual !== null) {
            postagens.push(atual.postagem);
            atual = atual.proximo;
        }
        return postagens;
    }

    consultarPostagem(id?: number, texto?: string, hashtag?: string, perfil?: Perfil): Postagem[] {
        const postagensFiltradas: Postagem[] = [];
        let atual = this.inicio;

        while (atual != null) {
            let postagem = atual.postagem;
            if (
                (id == undefined || postagem.idPostagem == id) &&
                (texto == undefined || postagem.texto == texto) &&
                (perfil == undefined || postagem.perfil == perfil)
            ) {
                if (hashtag != undefined && postagem instanceof PostagemAvancada && postagem.existeHashtag(hashtag)) {
                    postagensFiltradas.push(postagem);
                } else if (hashtag == undefined) {
                    postagensFiltradas.push(postagem);
                }
            }

            atual = atual.proximo;
        }

        return postagensFiltradas;
    }

    incluirPostagem(postagem: Postagem): void {
        const novoNo = new NoPostagem(postagem);

        if (this.inicio == null) {
            this.inicio = novoNo;
        } else {
            let atual = this.inicio;
            while (atual.proximo != null) {
                atual = atual.proximo;
            }
            atual.proximo = novoNo;
        }
    }

    consultarPorIndice(idPostagem: number): number {
        let atual = this.inicio;
        let indice = 0;

        while (atual !== null) {
            if (atual.postagem.idPostagem == idPostagem) {
                return indice;
            }
            
            atual = atual.proximo;
            indice ++;
        }

        throw new PostagemNaoEncontradaError('Postagem não encontrada') 
    }

    consultarPostagemPorId(idPost: number): Postagem {
        let atual = this.inicio;

        while (atual != null) {
            if (atual.postagem.idPostagem == idPost) {
                return atual.postagem;
            }

            atual = atual.proximo;
        }

        throw new PostagemNaoEncontradaError('Postagem não encontrada');
    }
    atualizarPostagem(postagem: Postagem): void {
        // ver forma de implementar esse metodo
    }
}


class RepositorioDePostagensArray implements IRepositorioPostagens{
    private _postagens: Postagem[] = [];

    get postagens(): Postagem[] { //adicionei
        return this._postagens;
    }

    consultarPostagem(id?: number, texto?: string, hashtag?: string, perfil?: Perfil): Postagem[]{
        let postagensFiltradas: Postagem[] = [];
    
        for (let p of this.postagens) { //!alterei postagens
            if ((id == undefined || p.idPostagem == id) &&
                (texto == undefined || p.texto == texto) &&
                (perfil == undefined || p.perfil == perfil)) {
                if (hashtag !== undefined && p instanceof PostagemAvancada && (p as PostagemAvancada).existeHashtag(hashtag)) {
                    postagensFiltradas.push(p);
                } else if (hashtag == undefined) {
                    postagensFiltradas.push(p);
                }
            }
        }
    
        try{
            if(postagensFiltradas.length == 0){
                throw new PostagemNaoEncontradaError('Postagem não encontrada!');
            }
        } catch (e: any) {
            if (e instanceof AplicacaoError) {
                console.log(e.message);
            }
        }

        return postagensFiltradas;
    }

    consultarPostagemPorId(idPost: number): Postagem{
        let postagemProcurada!: Postagem;

        for(let p of this._postagens){
            if(p.idPostagem == idPost){
                postagemProcurada = p
            }
        }

        try{
            if(!postagemProcurada){
                throw new PostagemNaoEncontradaError('Postagem não encontrada!');
            }
        } catch (e: any) {
            if (e instanceof AplicacaoError) {
                console.log(e.message);
            }
        }

        return postagemProcurada;
    }

    consultarPorIndice(id:number){
        let indiceProcurado: number = -1;
        try{
            for(let i = 0; i < this.postagens.length; i++){ //!alterei postagens
                if(this.postagens[i].idPostagem == id){
                    indiceProcurado = i;
                }
            }

            if(indiceProcurado == -1){
                throw new PostagemNaoEncontradaError('Essa postagem não exite!')
            }
        } catch(e: any){
            if (e instanceof AplicacaoError){
                console.log(e.message);
            }
        }

        return indiceProcurado;
    }

    incluirPostagem(postagem: Postagem){
        try{
            if (postagem.idPostagem && postagem.texto.trim() && postagem.perfil) {
                let postagemExiste = this.consultarPostagem(postagem.idPostagem);
        
                if (postagemExiste.length == 1) {
                    throw new PostagemJaExisteError('Já existe uma postagem com o mesmo id!');
                } 
            } else {
                throw new AtributoVazioError('Todos os atributos da postagem devem estar preenchidos!');
            }

            this._postagens.push(postagem)
            postagem.perfil.postagensDoPerfil.push(postagem);
            console.log('Postagem incluída com sucesso!');
        } catch (e: any) {
            if (e instanceof AplicacaoError) {
                console.log(e.message);
            }
        }
    }    
    atualizarPostagem(postagem: Postagem): void {
        // ver forma de implementar esse metodo
    }  
}

export { Perfil, Postagem, PostagemAvancada, RepositorioDePerfisArray, RepositorioDePostagensArray, IRepositorioDePerfis, IRepositorioPostagens, RepositorioDePerfisLista, RepositorioDePostagensLista, RepositorioDePerfisArquivo, RepositorioDePostagensArquivo }