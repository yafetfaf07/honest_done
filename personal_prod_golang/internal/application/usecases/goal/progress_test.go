package usecases

import "testing"

func TestProgressFromTasks(t *testing.T) {
	cases := []struct {
		name      string
		completed int
		total     int
		want      int
	}{
		{"no tasks", 0, 0, 0},
		{"none done", 0, 4, 0},
		{"half done", 2, 4, 50},
		{"all done", 4, 4, 100},
		{"one of one", 1, 1, 100},
		{"one of three rounds down", 1, 3, 33},
		{"two of three rounds up", 2, 3, 67},
		{"completed above total clamps", 5, 3, 100},
		{"negative completed clamps", -1, 4, 0},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			if got := ProgressFromTasks(tc.completed, tc.total); got != tc.want {
				t.Errorf("ProgressFromTasks(%d, %d) = %d, want %d",
					tc.completed, tc.total, got, tc.want)
			}
		})
	}
}

func TestProgressFromTasksNeverDividesByZero(t *testing.T) {
	// A goal with no tasks has nothing to divide by; it must report 0, not panic.
	if got := ProgressFromTasks(0, 0); got != 0 {
		t.Errorf("ProgressFromTasks(0, 0) = %d, want 0", got)
	}
}
