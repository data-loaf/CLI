package lists

import (
	command "dataloaf/cmd/commands"

	"github.com/charmbracelet/bubbles/list"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

var (
	titleText  = "DataLoaf 🍞"
	docStyle   = lipgloss.NewStyle().Margin(1, 2)
	titleStyle = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#F1D492")).
			Bold(true)
)

type item struct {
	title, desc string
}

func (i item) Title() string       { return i.title }
func (i item) Description() string { return i.desc }
func (i item) FilterValue() string { return i.title }

type Model struct {
	List      list.Model
	Selection string
	Active    bool
}

func (m Model) GetSelection() string {
	return m.Selection
}

func IsValidChoice(regionInput string) bool {
	for _, region := range Regions {
		if item, ok := region.(item); ok {
			if regionInput == item.title {
				return true
			}
		}
	}

	return false
}

func (m Model) Init() tea.Cmd {
	return nil
}

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		if msg.String() == "ctrl+c" {
			return m, tea.Quit
		}

		if msg.String() == "enter" {
			m.Selection = m.List.SelectedItem().(item).Title()
			return m, command.CustomQuit
		}
	case tea.WindowSizeMsg:
		h, v := docStyle.GetFrameSize()
		m.List.SetSize(msg.Width-h, msg.Height-v)
	}

	var cmd tea.Cmd
	m.List, cmd = m.List.Update(msg)
	return m, cmd
}

func (m Model) View() string {
	title := titleStyle.Render(titleText)
	return docStyle.Render(title, m.List.View())
}
