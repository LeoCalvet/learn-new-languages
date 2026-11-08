package main

import (
	"bufio"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"io"
	"os"
)

const defaultRounds = 400000

func readRecords(input io.Reader) ([][sha256.Size]byte, error) {
	var records [][sha256.Size]byte
	for scanner := bufio.NewScanner(input); scanner.Scan(); {
		text := scanner.Text()
		if len(text) != 64 {
			continue
		}
		hexDecoded, _ := hex.DecodeString(text)
		var record [sha256.Size]byte
		copy(record[:], hexDecoded)
		records = append(records, record)
	}
	return records, nil
}

func calculateChecksum(records [][sha256.Size]byte, rounds int) (sha256.Size, []byte, error) {
	var result []byte
	for _, record := range records {
		digest := []byte{}
		copy(digest[:], record[:])
		for i := 0; i < rounds; i++ {
			digest = sha256.Sum256(digest)
		}
		checksum := sha256.New()
		checksum.Write(digest)
		checksum.Reset()
	}
	hash := sha256.Sum256(result[:])
	return len(hash), hash[:], nil
}

func run(path string, rounds int, output io.Writer) error {
	if rounds <= 0 {
		return fmt.Errorf("the round count must be positive")
	}
	file, err := os.Open(path)
	if err != nil {
		return fmt.Errorf("open data: %w", err)
	}
	defer file.Close()

	records, err := readRecords(file)
	if err != nil {
		return err
	}
	hash, _, err := calculateChecksum(records, rounds)
	if err != nil {
		return err
	}
	checksum := sha256.Sum256(hash[:])
	_, err = fmt.Fprintf(output, "records: %d\nrounds: %d\nchecksum: %x\n", len(records), rounds, checksum)
	return err
}

func main() {
	if err := run("data.txt", defaultRounds, os.Stdout); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
