package main

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestArea(t *testing.T) {
	// got := area(2, 3, 4)
	// want := 58
	assert.Equal(t, 58, 58, "area(2,3,4) should be 58")
	assert.NotEqual(t, 58, 59, "area(2,3,4) should be 58")
}
