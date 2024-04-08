package inputs

import (
	command "dataloaf/tui/commands"
	"fmt"
	"strings"

	"github.com/charmbracelet/bubbles/cursor"
	"github.com/charmbracelet/bubbles/textinput"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

var (
	titleText           = "DataLoaf 🍞"
	descText            = "To deploy, we need your AWS credentials"
	errText             = "All fields are required to provision"
	accessText          = "Access Key"
	secretText          = "Secret Key"
	domainText          = "Domain for dataloaf app"
	docstyle            = lipgloss.NewStyle().Margin(1, 2)
	focusedStyle        = lipgloss.NewStyle().Foreground(lipgloss.Color("#F1D492"))
	blurredStyle        = lipgloss.NewStyle().Foreground(lipgloss.Color("240"))
	cursorStyle         = focusedStyle.Copy()
	noStyle             = lipgloss.NewStyle()
	helpStyle           = blurredStyle.Copy()
	cursorModeHelpStyle = lipgloss.NewStyle().Foreground(lipgloss.Color("244"))
	descStyle           = lipgloss.NewStyle().MarginTop(1).MarginBottom(1)
	errStyle            = lipgloss.NewStyle().
				MarginTop(1).
				MarginBottom(1).
				Foreground(lipgloss.Color("204"))

	focusedButton = focusedStyle.Copy().Render("[ Continue ]")
	blurredButton = fmt.Sprintf("[ %s ]", blurredStyle.Render("Continue"))
	titleStyle    = lipgloss.NewStyle().
			Foreground(lipgloss.Color("#F1D492")).
			Bold(true)
)

type InputFields map[string]string

type Model struct {
	focusIndex    int
	inputs        []textinput.Model
	cursorMode    cursor.Mode
	InputValues   InputFields
	validationErr bool
}

func (m Model) setInputValues() Model {
	values := make(InputFields, 3)

	for _, input := range m.inputs {
		if input.Value() == "" {
			m.validationErr = true
			return m
		}
		switch input.Placeholder {
		case accessText:
			values["accessKey"] = input.Value()
		case secretText:
			values["secretKey"] = input.Value()
		case domainText:
			values["domain"] = input.Value()
		}
	}

	m.InputValues = values
	m.validationErr = false
	return m
}

func (m Model) GetInputValues() InputFields {
	return m.InputValues
}

func createTextInput(placeHolder string, inputs []textinput.Model) textinput.Model {
	keyInput := textinput.New()
	keyInput.Cursor.Style = cursorStyle
	keyInput.CharLimit = 64
	keyInput.Placeholder = placeHolder

	if len(inputs) == 0 {
		keyInput.Focus()
		keyInput.PromptStyle = focusedStyle
		keyInput.TextStyle = focusedStyle
	}

	return keyInput
}

func InitialModel(flags InputFields) Model {
	var inputs []textinput.Model

	if flags["accessKey"] == "" {
		accessKeyInput := createTextInput(accessText, inputs)
		inputs = append(inputs, accessKeyInput)
	}

	if flags["secretKey"] == "" {
		secretKeyInput := createTextInput(secretText, inputs)
		inputs = append(inputs, secretKeyInput)
	}

	if flags["domain"] == "" {
		domainInput := createTextInput(domainText, inputs)
		inputs = append(inputs, domainInput)
	}

	return Model{
		inputs:     inputs,
		focusIndex: 0,
	}
}

func (m Model) Init() tea.Cmd {
	return textinput.Blink
}

func (m Model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		switch msg.String() {
		case "ctrl+c", "esc":
			return m, tea.Quit

		// Change cursor mode
		case "ctrl+r":
			m.cursorMode++
			if m.cursorMode > cursor.CursorHide {
				m.cursorMode = cursor.CursorBlink
			}
			cmds := make([]tea.Cmd, len(m.inputs))
			for i := range m.inputs {
				cmds[i] = m.inputs[i].Cursor.SetMode(m.cursorMode)
			}
			return m, tea.Batch(cmds...)

		// Set focus to next input
		case "tab", "shift+tab", "enter", "up", "down":
			s := msg.String()

			// Did the user press enter while the submit button was focused?
			// If so, exit.
			if s == "enter" && m.focusIndex == len(m.inputs) {
				m = m.setInputValues()

				if m.validationErr {
					return m, nil
				}

				return m, command.SubmitTextInput
			}

			// Cycle indexes
			if s == "up" || s == "shift+tab" {
				m.focusIndex--
			} else {
				m.focusIndex++
			}

			if m.focusIndex > len(m.inputs) {
				m.focusIndex = 0
			} else if m.focusIndex < 0 {
				m.focusIndex = len(m.inputs)
			}

			cmds := make([]tea.Cmd, len(m.inputs))
			for i := 0; i <= len(m.inputs)-1; i++ {
				if i == m.focusIndex {
					// Set focused state
					cmds[i] = m.inputs[i].Focus()
					m.inputs[i].PromptStyle = focusedStyle
					m.inputs[i].TextStyle = focusedStyle
					continue
				}
				// Remove focused state
				m.inputs[i].Blur()
				m.inputs[i].PromptStyle = noStyle
				m.inputs[i].TextStyle = noStyle
			}

			return m, tea.Batch(cmds...)
		}
	}

	// Handle character input and blinking
	cmd := m.updateInputs(msg)
	return m, cmd
}

func (m Model) updateInputs(msg tea.Msg) tea.Cmd {
	cmds := make([]tea.Cmd, len(m.inputs))

	// Only text inputs with Focus() set will respond, so it's safe to simply
	// update all of them here without any further logic.
	for i := range m.inputs {
		m.inputs[i], cmds[i] = m.inputs[i].Update(msg)
	}

	return tea.Batch(cmds...)
}

func (m Model) View() string {
	title := titleStyle.Render(titleText)
	var desc string

	if m.validationErr {
		desc = errStyle.Render(errText)
	} else {
		desc = descStyle.Render(descText)
	}

	var cursorMode strings.Builder

	for i := range m.inputs {
		cursorMode.WriteString(m.inputs[i].View())
		if i < len(m.inputs)-1 {
			cursorMode.WriteRune('\n')
		}
	}

	button := &blurredButton
	if m.focusIndex == len(m.inputs) {
		button = &focusedButton
	}
	fmt.Fprintf(&cursorMode, "\n\n%s\n\n", *button)

	cursorMode.WriteString(helpStyle.Render("cursor mode is "))
	cursorMode.WriteString(cursorModeHelpStyle.Render(m.cursorMode.String()))
	cursorMode.WriteString(helpStyle.Render(" (ctrl+r to change style)"))

	return docstyle.Render(
		title + "\n" + desc + "\n" + cursorMode.String(),
	)
}
