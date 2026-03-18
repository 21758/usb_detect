// Command gui provides the Fyne GUI application
package main

import (
	"log"

	"github.com/sd-detect/pkg/ui"
)

func main() {
	log.SetFlags(log.Lshortfile)

	app := ui.NewApp()
	app.CreateAndRun()
}
