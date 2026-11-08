package main

import "testing"

func TestArea(t *testing.T) {
	got := area(2, 3, 4)
	want := 58

	if got != want {
		t.Errorf("got %d, want %d", got, want)
	}
}
