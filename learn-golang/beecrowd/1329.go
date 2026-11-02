package main

import "fmt"

func main() {
	var qtd_n int

	for {
		fmt.Print("Valor de N quantidade de partidas: ")
		fmt.Scan(&qtd_n)
		if qtd_n == 0 {
			break
		}

		partidas := make([]bool, qtd_n)
		fmt.Print("Liste a baixo as partidas: ")
		for i := 0; i < qtd_n; i++ {
			fmt.Scan(&partidas[i])
		}
		total_maria := 0
		total_joao := 0
		for _, resultado := range partidas {
			if resultado == true {
				total_joao++
			} else {
				total_maria++
			}
		}
		fmt.Printf("Mary won %d times and John won %d times\n", total_maria, total_joao)
	}
}

/*
 * ENTRADA:
 * Numero de vezes (1 ≤ N ≤ 10000)
 * Quando de jogos => 0 1 0 1 => 0 é Maria E 1 é João
 * Se N = 0 = fim
 */
