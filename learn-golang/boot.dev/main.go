package main

import "fmt"

func main() {
	var num1, num2, num3 float64

	_, err := fmt.Scanf("%f\n%f", &num1, &num2)
	if err != nil {
		fmt.Println(err)
		return
	}

	num3 = ((num1 * 3.5) + (num2 * 7.5)) / 11

	fmt.Printf("MEDIA = %.5f\n", num3)
}
