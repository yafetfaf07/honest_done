package entities

// GoalTaskCounts carries per-goal task tallies used to derive goal progress.
type GoalTaskCounts struct {
	GoalID    string
	Total     int
	Completed int
}
