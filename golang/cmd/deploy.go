package cmd

import (
	app "dataloaf/cmd/app"
	inputs "dataloaf/cmd/inputs"
	lists "dataloaf/cmd/lists"
	"fmt"

	list "github.com/charmbracelet/bubbles/list"
	"github.com/charmbracelet/lipgloss"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/spf13/cobra"
)

func mergeFlagsAndInputs(
	flags inputs.InputFields,
	inputs inputs.InputFields,
) inputs.InputFields {
	mergedInputs := make(map[string]string)

	for key, value := range flags {
		mergedInputs[key] = value
	}

	for key, value := range inputs {
		mergedInputs[key] = value
	}

	return mergedInputs
}

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

func executeDeploy(cmd *cobra.Command, args []string) {
	accessKey, _ := cmd.Flags().GetString("access")
	secretKey, _ := cmd.Flags().GetString("secret")
	domain, _ := cmd.Flags().GetString("domain")
	region, _ := cmd.Flags().GetString("region")

	flags := inputs.InputFields{
		"AccessKey": accessKey,
		"SecretKey": secretKey,
		"Domain":    domain,
	}

	inputsModel := initInputsModel(flags)
	listModel := initListModel()
	appModel := app.Model{InputsModel: inputsModel, ListModel: listModel}

	viewsRequired := new(app.ViewsRequired)
	currentView := appModel.SessionView

	if flags["AccessKey"] == "" || flags["SecretKey"] == "" || flags["Domain"] == "" {
		currentView = app.InputsView
		viewsRequired.InputFields = true
	}

	if !lists.IsValidChoice(region) {
		if currentView != app.InputsView {
			currentView = app.ListView
		}
		viewsRequired.ListSelection = true
	} else {
		viewsRequired.ListSelection = false
	}

	appModel.ViewsRequired = *viewsRequired
	appModel.SessionView = currentView
	fmt.Println(appModel.ViewsRequired, appModel.SessionView)

	if appModel.SessionView != 0 {
		if _, err := tea.NewProgram(appModel, tea.WithAltScreen()).Run(); err != nil {
			fmt.Printf("could not start program: %s\n", err)
		}
	}

	// TODO: Merge flags with bubble tea outputs
	resultData := app.GetData()
	fmt.Println(resultData)
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
	deployCmd.Flags().StringP("domain", "d", "", "Domain you want to use for DataLoaf app")
}
