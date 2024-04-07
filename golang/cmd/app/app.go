package app

import (
	command "dataloaf/cmd/commands"
	inputs "dataloaf/cmd/inputs"
	"dataloaf/cmd/lists"

	tea "github.com/charmbracelet/bubbletea"
)

type sessionView int

const (
	InputsView sessionView = iota + 1
	ListView
)

type ViewsRequired struct {
	InputFields   bool
	ListSelection bool
}

type Model struct {
	SessionView   sessionView
	InputsModel   tea.Model
	ListModel     tea.Model
	ViewsRequired ViewsRequired
}

type resultData struct {
	inputFields   inputs.InputFields
	listSelection string
}

var result resultData

func GetData() resultData {
	return result
}

func (m Model) setResultData() {
	inputFields := m.InputsModel.(inputs.Model).InputValues
	region := m.ListModel.(lists.Model).Selection

	result = resultData{inputFields, region}
}

func (m Model) Init() tea.Cmd {
	switch m.SessionView {
	case InputsView:
		return m.InputsModel.Init()
	case ListView:
		return m.ListModel.Init()
	}

	return nil
}

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	var cmds []tea.Cmd

	switch msg.(type) {
	case command.SubmitTextInputMsg:
		m.SessionView = ListView

	case tea.WindowSizeMsg:
		listModel, cmd := m.ListModel.Update(msg)
		m.ListModel = listModel
		cmds = append(cmds, cmd)

	case command.CustomQuitMsg:
		m.setResultData()
		return m, tea.Quit
	}

	switch m.SessionView {
	case InputsView:
		if !m.ViewsRequired.InputFields {
			return m, command.CustomQuit
		}
		inputsModel, cmd := m.InputsModel.Update(msg)
		m.InputsModel = inputsModel
		cmds = append(cmds, cmd)
	case ListView:
		if !m.ViewsRequired.ListSelection {
			return m, command.CustomQuit
		}
		listModel, cmd := m.ListModel.Update(msg)
		m.ListModel = listModel
		cmds = append(cmds, cmd)
	}

	return m, tea.Batch(cmds...)
}

func (m Model) View() string {
	switch m.SessionView {
	case InputsView:
		return m.InputsModel.View()

	case ListView:
		return m.ListModel.View()
	}

	return ""
}
