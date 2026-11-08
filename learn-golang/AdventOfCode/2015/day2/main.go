package main

import (
	"fmt"
)

// type Area struct {
// 	lengh, width, height int
// }

func area(lengh, width, height int) int {
	var areaTotal int
	area1 := lengh * width
	area2 := lengh * height
	area3 := width * height
	areaTotal = 2*area1 + 2*area2 + 2*area3
	menor := min(area1, area2, area3)
	return areaTotal + menor
}

func main() {
	var lengh, width, height int
	_, err := fmt.Scanf("%d %d %d", &lengh, &width, &height)

	if err != nil {
		panic(err)
	}

	result := area(lengh, width, height)
	fmt.Printf("%d", result)
}
