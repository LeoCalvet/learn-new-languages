package main

import "fmt"

func main() {
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
