package main

import (
	"bufio"
	"fmt"
	"math/rand"
	"os"
	"strconv"
	"strings"
	"time"
)

func main() {
	// Create a new random source seeded with current time
	source := rand.NewSource(time.Now().UnixNano())
	rng := rand.New(source)

	// Create a reader for user input
	reader := bufio.NewReader(os.Stdin)

	fmt.Println("=== Dice Roller Program ===")
	fmt.Println("Type 'quit' to exit the program")
	fmt.Println()

	// Get the number of faces for the dice
	fmt.Print("How many faces does your dice have? ")
	input, err := reader.ReadString('\n')
	if err != nil {
		fmt.Println("Error reading input:", err)
		return
	}

	// Clean and convert the input
	input = strings.TrimSpace(input)

	// Check if user wants to quit at the beginning
	if strings.ToLower(input) == "quit" {
		fmt.Println("Goodbye!")
		return
	}

	// Convert to integer
	faces, err := strconv.Atoi(input)
	if err != nil || faces <= 0 {
		fmt.Println("Please enter a valid positive number")
		return
	}

	fmt.Printf("Dice with %d faces created! Range: [1..%d]\n", faces, faces)
	fmt.Println("Press Enter to roll the dice (or type 'quit' to stop)")
	fmt.Println()

	// Main loop
	for {
		fmt.Print("Roll the dice? ")
		input, err := reader.ReadString('\n')
		if err != nil {
			fmt.Println("Error reading input:", err)
			continue
		}

		// Clean the input
		input = strings.TrimSpace(input)

		// Check if user wants to quit
		if strings.ToLower(input) == "quit" {
			fmt.Println("Thanks for playing! Goodbye!")
			break
		}

		// Roll the dice using our custom random generator
		result := rng.Intn(faces) + 1 // +1 to get range [1..faces]
		fmt.Printf("You rolled: %d\n", result)
		fmt.Println()
	}
}
