/*1) Enumere os 3 tipos mais comuns de tratamento de erros e exemplifique com
códigos seus ou pesquisados na internet.

-> Os três tipos são: 
-Desconsiderar a operação; 
-Exibir mensagem de erro; e 
-Retornar um código de erro*/

//desconsiderar a operação - ficamos em dúvida quanto ao método se ele esta funcionando ou não
class Calculadora1 {
    private _operando1: number;
    private _operando2: number;

    constructor(_operando1: number, _operando2: number) {
        this._operando1 = _operando1;
        this._operando2 = _operando2;
    }

    soma (): void {
        if (this._operando1 != null && this._operando2 != null) {
            this._operando1 + this._operando2;
        }
    }
}

//Exibir mensagem de erro - a mensagem fica restrita somente a interface texto do terminal, caso estivesse em uma interface gráfica a mensagem não seria notada
class Calculadora2 {
    private _operando1: number;
    private _operando2: number;

    constructor(_operando1: number, _operando2: number) {
        this._operando1 = _operando1;
        this._operando2 = _operando2;
    }

    soma (): string {
        if (this._operando1 != null && this._operando2 != null) {
            this._operando1 + this._operando2;
            return 'Operação realizada';   
        }
        return 'Valor inválido!';
    }
}

//Retornar um código de erro - nesse caso é necessário associar o valor ao retorno do erro e executar testes para saber o que houve
class Calculadora3 {
    private _operando1: number;
    private _operando2: number;

    constructor(_operando1: number, _operando2: number) {
        this._operando1 = _operando1;
        this._operando2 = _operando2;
    }

    soma (): boolean {
        if (this._operando1 != null && this._operando2 != null) {
            this._operando1 + this._operando2;
            return true;   
        }
        return false;
    }
}