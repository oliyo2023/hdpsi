package main

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var rootCmd = &cobra.Command{
	Use:   "hdpsi",
	Short: "HD PSI 系统管理工具",
	Long: `HD PSI 系统管理工具是一个命令行工具，用于管理HD PSI系统的各种资源，
包括用户、商品、库存等。使用子命令来访问不同的功能。`,
}

func main() {
	// 添加子命令
	rootCmd.AddCommand(userCmd)
	rootCmd.AddCommand(productCmd)
	rootCmd.AddCommand(batchProductCmd)

	// 执行命令
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}
