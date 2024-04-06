package cmd

import (
	inputs "dataloaf/cmd/inputs"
	lists "dataloaf/cmd/lists"
	"fmt"
	"os"

	list "github.com/charmbracelet/bubbles/list"
	"github.com/charmbracelet/lipgloss"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/spf13/cobra"
)

func mergeFlagsAndInputs(
	flags inputs.TextInputFields,
	inputs inputs.TextInputFields,
) inputs.TextInputFields {
	mergedInputs := make(map[string]string)

	for key, value := range flags {
		mergedInputs[key] = value
	}

	for key, value := range inputs {
		mergedInputs[key] = value
	}

	return mergedInputs
}

func executeInputForm(flags inputs.TextInputFields) inputs.TextInputFields {
	modelTextInputs := inputs.InitialModel(flags)

	if flags["AccessKey"] == "" || flags["SecretKey"] == "" || flags["Domain"] == "" {
		if _, err := tea.NewProgram(modelTextInputs, tea.WithAltScreen()).Run(); err != nil {
			fmt.Printf("could not start program: %s\n", err)
		}
	}

	if modelTextInputs.Exited == true {
		os.Exit(0)
	}

	resultInputs := modelTextInputs.GetInputValues()
	return mergeFlagsAndInputs(flags, resultInputs)
}

func executeListSelection() string {
	items := lists.Regions
	d := list.NewDefaultDelegate()
	d.Styles.SelectedTitle = lipgloss.NewStyle().Foreground(lipgloss.Color("#F1D492"))
	d.Styles.SelectedDesc = lipgloss.NewStyle().Foreground(lipgloss.Color("#D68A2E"))

	l := list.New(items, d, 0, 0)
	l.Title = "\nSelect a region"
	l.Styles.Title = lipgloss.NewStyle().Foreground(lipgloss.Color("240"))
	l.Styles.TitleBar.PaddingTop(1).PaddingBottom(1).PaddingLeft(0)

	regionModel := &lists.Model{List: l}
	p := tea.NewProgram(regionModel, tea.WithAltScreen())

	if _, err := p.Run(); err != nil {
		fmt.Println("Error running program:", err)
		os.Exit(1)
	}

	return regionModel.GetSelection()
}

func executeDeploy(cmd *cobra.Command, args []string) {
	accessKey, _ := cmd.Flags().GetString("access")
	secretKey, _ := cmd.Flags().GetString("secret")
	domain, _ := cmd.Flags().GetString("domain")
	region, _ := cmd.Flags().GetString("region")

	flags := inputs.TextInputFields{
		"AccessKey": accessKey,
		"SecretKey": secretKey,
		"Domain":    domain,
	}

	resultKeyInput := executeInputForm(flags)
	resultRegionInput := ""

	if lists.IsValidChoice(region) {
		resultRegionInput = region
	} else {
		resultRegionInput = executeListSelection()
	}

	fmt.Printf("Final selections are %v and %s", resultKeyInput, resultRegionInput)
}

// deployCmd represents the deploy command
var deployCmd = &cobra.Command{
	Use:   "deploy",
	Short: "Deploy your infrastructure to AWS (powered by terraform)",
	Long:  ``,
	Run:   executeDeploy,
}

func init() {
	rootCmd.AddCommand(deployCmd)
	deployCmd.Flags().StringP("access", "a", "", "Your AWS Access Key")
	deployCmd.Flags().StringP("secret", "s", "", "Your AWS Secret Key")
	deployCmd.Flags().StringP("region", "r", "", "Your AWS region")
}
