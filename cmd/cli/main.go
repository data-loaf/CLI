package main

import (
	command "dataloaf/cli/commands"
	"fmt"
)

var BuildDir string

func main() {
	fmt.Println(BuildDir)
	command.Execute()
}
