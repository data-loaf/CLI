package cmd

import (
	inputs "dataloaf/cmd/inputs"
	"fmt"
	"os"

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

func executeDeploy(cmd *cobra.Command, args []string) {
	accessKey, _ := cmd.Flags().GetString("access")
	secretKey, _ := cmd.Flags().GetString("secret")
	// region, _ := cmd.Flags().GetString("region")

	flags := inputs.TextInputFields{"AccessKey": accessKey, "SecretKey": secretKey}
	fmt.Println(flags)
	model := inputs.InitialModel(flags)

	if accessKey == "" || secretKey == "" {
		if _, err := tea.NewProgram(model).Run(); err != nil {
			fmt.Printf("could not start program: %s\n", err)
			os.Exit(1)
		}
	}

	resultInputs := inputs.TextResults
	mergedResult := mergeFlagsAndInputs(flags, resultInputs)

	fmt.Println(mergedResult)
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
