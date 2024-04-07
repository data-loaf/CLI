package commands

import (
	tea "github.com/charmbracelet/bubbletea"
)

type (
	CustomQuitMsg      struct{}
	SubmitTextInputMsg struct{}
)

func CustomQuit() tea.Msg {
	return CustomQuitMsg{}
}

func SubmitTextInput() tea.Msg {
	return SubmitTextInputMsg{}
}
