/*
- start at floor 0
( => Go up
) => Go down

What to I need to do for this challange?
1. How can I read a file?
2. How will I decide the final result?
2.1. get the total size of the array
2.2. check how many are "("
2.3. the rest will be ")" so do not need keep adding two variables
> Extra: use goroutines to look in parallel for each character
*/

package main

import (
	"fmt"
	"os"
)

type Resultado struct {
	up   int
	down int
}

func calculo_andar_final(linha string) Resultado {
	tamanho_total := len(linha)
	go_up := 0
	for i := 0; i < tamanho_total; i++ {
		caracter := linha[i]
		if caracter == '(' {
			go_up++
		}
	}
	go_down := tamanho_total - go_up
	resultado := Resultado{go_up, go_down}
	return resultado
}

func main() {
	data, err := os.ReadFile("input")
	if err != nil {
		panic(err)
	}

	resultado := calculo_andar_final(string(data))
	fmt.Printf("%d | %d\n", resultado.up, resultado.down)
}
