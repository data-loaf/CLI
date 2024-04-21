package commands

import (
	tea "github.com/charmbracelet/bubbletea"
)

type (
	CustomQuitMsg      struct{}
	SubmitTextInputMsg struct{}
	AbortedMsg         struct{}
)

func CustomQuit() tea.Msg {
	return CustomQuitMsg{}
}

func Aborted() tea.Msg {
	return AbortedMsg{}
}

func SubmitTextInput() tea.Msg {
	return SubmitTextInputMsg{}
}
