package main

import (
	"biblioteca/banco"
	"biblioteca/rotas"
	"log"
	"net/http"

	"github.com/joho/godotenv"
)

func main() {

	if err := godotenv.Load(); err != nil {
		log.Fatal("Erro ao carregar variáveis de ambiente!")
	}

	banco.Inicializar()
	defer banco.Finalizar()
	http.HandleFunc("/login", rotas.Login)
	http.HandleFunc("/usuario", rotas.Usuario)
	http.HandleFunc("/autor", rotas.Autor)
	http.HandleFunc("/recuperarsenha", rotas.RecuperarSenha)
	http.ListenAndServe(":9090", nil)
}
