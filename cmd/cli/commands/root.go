package commands

import (
	"os"

	"github.com/spf13/cobra"
)

// RootCmd represents the base command when called without any subcommands
var RootCmd = &cobra.Command{
	Use:   "loaf",
	Short: "DataLoaf",
	Long:  ``,
}

// Execute adds all child commands to the root command and sets flags appropriately.
func Execute() {
	err := RootCmd.Execute()
	if err != nil {
		os.Exit(1)
	}
}

func addCommands() {
	RootCmd.AddCommand(DeployCmd)
	RootCmd.AddCommand(RemoveCmd)
}

func init() {
	RootCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
	addCommands()
}
