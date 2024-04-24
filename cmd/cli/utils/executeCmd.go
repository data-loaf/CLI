package utils

import (
	app "dataloaf/tui/app"
	"fmt"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/spf13/cobra"
)

func ExecuteCmd(cmd *cobra.Command, args []string) {
	loafCmd := cmd.Name()
	flags := allFlags(cmd)
	appModel := InitModel(flags.Inputs, flags.List)

	if appModel.SessionView != 0 {
		if _, err := tea.NewProgram(appModel, tea.WithAltScreen()).Run(); err != nil {
			fmt.Printf("could not start program: %s\n", err)
		}
	}

	if app.IsAborted() {
		return
	}

	resultData := app.GetData()
	mergedInputs := mergeFlagsAndInputs(flags.Inputs, resultData.InputFields)
	mergedList := mergeFlagsAndListSelection(flags.List, resultData.ListSelection)

	err := RunTerraform(loafCmd, mergedInputs, mergedList)
	if err != nil {
		fmt.Println("Error:", err)
	}
}
