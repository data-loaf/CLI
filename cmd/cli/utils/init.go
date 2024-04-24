package utils

import (
	inputs "dataloaf/tui/inputs"
	lists "dataloaf/tui/lists"

	list "github.com/charmbracelet/bubbles/list"
	"github.com/charmbracelet/lipgloss"

	app "dataloaf/tui/app"
	tea "github.com/charmbracelet/bubbletea"
)

func initInputsModel(flags inputs.InputFields) tea.Model {
	modelTextInputs := inputs.InitialModel(flags)
	return modelTextInputs
}

func initListModel() tea.Model {
	items := lists.Regions
	d := list.NewDefaultDelegate()
	d.Styles.SelectedTitle = lipgloss.NewStyle().Foreground(lipgloss.Color("#F1D492"))
	d.Styles.SelectedDesc = lipgloss.NewStyle().Foreground(lipgloss.Color("#D68A2E"))

	l := list.New(items, d, 0, 0)
	l.Title = "\nSelect a region"
	l.Styles.Title = lipgloss.NewStyle().Foreground(lipgloss.Color("240"))
	l.Styles.TitleBar.PaddingTop(1).PaddingBottom(1).PaddingLeft(0)

	regionModel := lists.Model{List: l}
	return regionModel
}

func InitModel(inputFlags inputs.InputFields, listFlag string) app.Model {
	inputsModel := initInputsModel(inputFlags)
	listModel := initListModel()
	appModel := app.Model{InputsModel: inputsModel, ListModel: listModel}

	viewsRequired := *new(app.ViewsRequired)
	currentView := appModel.SessionView

	if len(inputFlags["accessKey"]) == 0 || len(inputFlags["secretKey"]) == 0 ||
		len(inputFlags["domain"]) == 0 {
		currentView = app.InputsView
		viewsRequired.InputFields = true
	}

	if !lists.IsValidChoice(listFlag) {
		if currentView != app.InputsView {
			currentView = app.ListView
		}
		viewsRequired.ListSelection = true
	} else {
		viewsRequired.ListSelection = false
	}

	appModel.ViewsRequired = viewsRequired
	appModel.SessionView = currentView
	return appModel
}
