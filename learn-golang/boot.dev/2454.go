package main

import "fmt"

/*
beecrowd | 2454 - Flíper
Por OBI - Olimpíada Brasileira de Informática 2014, Brasil
Timelimit: 1

Flíper é um tipo de jogo onde uma bolinha de metal cai por um labirinto de caminhos
até chegar na parte de baixo do labirinto. A quantidade de pontos que o jogador
ganha depende do caminho que a bolinha seguir. O jogador pode controlar o percurso
da bolinha mudando a posição de algumas portinhas do labirinto. Cada portinha pode
estar na posição 0, que significa virada para a esquerda, ou na posição 1 que quer
dizer virada para a direita. Considere o flíper da figura abaixo, que tem duas
portinhas. A portinha P está na posição 1 e a portinha R, na posição 0. Desse jeito,
a bolinha vai cair pelo caminho B.

Figura (esquema dos caminhos):

	 bolinha
	    |
	    v
	    P
	   / \
	  R   \
	 / \   \
	A   B   C

A figura mostra P virada para a direita (posição 1) e R virada para a esquerda
(posição 0).

Você deve escrever um programa que, dadas as posições das portinhas P e R, neste
flíper da figura, diga por qual dos três caminhos, A, B ou C, a bolinha vai cair!

# Entrada

A entrada é composta por apenas uma linha contendo dois números P (0 ou 1) e
R (0 ou 1), indicando as posições das duas portinhas do flíper da figura.

# Saída

A saída do seu programa deve ser também apenas uma linha, contendo uma letra
maiúscula que indica o caminho por onde a bolinha vai cair: 'A', 'B' ou 'C'.

# Exemplo de Entrada 1

1 0

# Exemplo de Saída 1

# B

# Exemplo de Entrada 2

0 0

# Exemplo de Saída 2

# C

OBI - Olimpíada Brasileira de Informática 2014 Fase 1 Nível Júnior
*/
func main() {

	/*
		 * Entao pelo texto eu vejo que posso fazer as seguintes certezas
			* 1. tem 3 resultados finais
			* 2. tem os seguintes resultados que vai levar para os 3 resultados finais
			* 2.1. 0 X já vai levar para C, pois começa com 0 sempre vai para o C
			* 2.2. 1 X ele pode ter duas possibilidas
			* 2.2.1. 1 0 ele vai levar para o B
			* 2.2.2. 1 1 ele vai levar para o A
		* Em resumo é uma verificação de estado
		* Para isso tenho que saber:
		* - if elsa
		* - ...
	*/

	// V1
	// 	var chave_P, chave_R bool
	//
	// 	_, _ = fmt.Scanf("%t %t", &chave_P, &chave_R)
	//
	// 	if chave_P == true {
	// 		if chave_R == true {
	// 			fmt.Println("A")
	// 		} else {
	// 			fmt.Println("B")
	// 		}
	// 	} else {
	// 		fmt.Println("C")
	// 	}

	var chave_P, chave_R bool

	_, err := fmt.Scanf("%t %t", &chave_P, &chave_R)

	if err != nil {
		fmt.Println("Só é aceito booleano")
		return
	}

	if chave_P == true {
		if chave_R == true {
			fmt.Println("A")
		} else {
			fmt.Println("B")
		}
	} else {
		fmt.Println("C")
	}
}
