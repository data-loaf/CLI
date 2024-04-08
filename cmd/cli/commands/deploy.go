package commands

import (
	"bufio"
	app "dataloaf/tui/app"
	inputs "dataloaf/tui/inputs"
	lists "dataloaf/tui/lists"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strings"

	list "github.com/charmbracelet/bubbles/list"
	"github.com/charmbracelet/lipgloss"

	tea "github.com/charmbracelet/bubbletea"
	"github.com/spf13/cobra"
)

var terraformExe string = "/../../terraform/bin/tf_deploy.sh"

func mergeFlagsAndInputs(
	inputFlags inputs.InputFields,
	inputResults inputs.InputFields,
) inputs.InputFields {
	mergedInputs := make(map[string]string)

	for key, value := range inputFlags {
		mergedInputs[key] = value
	}

	for key, value := range inputResults {
		mergedInputs[key] = value
	}

	return mergedInputs
}

func mergeFlagsAndListSelection(
	region string,
	selection string,
) string {
	if region != "" {
		return region
	} else {
		return selection
	}
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

func printOutput(pipe io.Reader) {
	scanner := bufio.NewScanner(pipe)
	for scanner.Scan() {
		fmt.Println(scanner.Text())
	}
}

func runTerraform(mergedInputs inputs.InputFields, mergedList lists.Selection) {
	var args []string

	for _, val := range mergedInputs {
		args = append(args, strings.TrimSpace(val))
	}

	args = append(args, mergedList)

	if slices.Contains(args, "") {
		return
	}

	exePath, err := os.Executable()
	if err != nil {
		fmt.Println("Error", err)
		return
	}

	exeDir := filepath.Dir(exePath)
	runTf := fmt.Sprintf("%s%s %s", exeDir, terraformExe, strings.Join(args, " "))

	cmd := exec.Command(
		"bash",
		"-c",
		runTf,
	)

	stdoutPipe, _ := cmd.StdoutPipe()
	stderrPipe, _ := cmd.StderrPipe()

	if err := cmd.Start(); err != nil {
		fmt.Println("Error:", err)
	}

	go printOutput(stdoutPipe)
	go printOutput(stderrPipe)

	if err := cmd.Wait(); err != nil {
		fmt.Println("Error:", err)
		return
	}
}

func executeDeploy(cmd *cobra.Command, args []string) {
	accessKey, _ := cmd.Flags().GetString("access")
	secretKey, _ := cmd.Flags().GetString("secret")
	domain, _ := cmd.Flags().GetString("domain")
	region, _ := cmd.Flags().GetString("region")

	inputFlags := inputs.InputFields{
		"AccessKey": accessKey,
		"SecretKey": secretKey,
		"Domain":    domain,
	}

	var listFlag lists.Selection = region

	inputsModel := initInputsModel(inputFlags)
	listModel := initListModel()
	appModel := app.Model{InputsModel: inputsModel, ListModel: listModel}

	viewsRequired := *new(app.ViewsRequired)
	currentView := appModel.SessionView

	if inputFlags["AccessKey"] == "" || inputFlags["SecretKey"] == "" ||
		inputFlags["Domain"] == "" {
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

	if appModel.SessionView != 0 {
		if _, err := tea.NewProgram(appModel, tea.WithAltScreen()).Run(); err != nil {
			fmt.Printf("could not start program: %s\n", err)
		}
	}

	resultData := app.GetData()
	mergedInputs := mergeFlagsAndInputs(inputFlags, resultData.InputFields)
	mergedList := mergeFlagsAndListSelection(listFlag, resultData.ListSelection)
	runTerraform(mergedInputs, mergedList)
}

// DeployCmd represents the deploy command
var DeployCmd = &cobra.Command{
	Use:   "deploy",
	Short: "Deploy your infrastructure to AWS (powered by terraform)",
	Long:  ``,
	Run:   executeDeploy,
}

func init() {
	DeployCmd.Flags().StringP("access", "a", "", "Your AWS Access Key")
	DeployCmd.Flags().StringP("secret", "s", "", "Your AWS Secret Key")
	DeployCmd.Flags().StringP("region", "r", "", "Your AWS region")
	DeployCmd.Flags().StringP("domain", "d", "", "Domain you want to use for DataLoaf app")
}
