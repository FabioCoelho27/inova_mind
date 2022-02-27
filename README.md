# Quotes Crawler

Crawler que busca frases no website <a href="http://quotes.toscrape.com/">Quotes to Scrape</a> a partir de determinada categoria.

## 1. Primeiros passos

Este projeto foi desenvolvido usando as seguintes tecnologias com as seguintes versões:

- Ruby 2.7.0p0
- Rails 6.0.4.6
- Mongoid 7.0.5
- Redis
- Sidekiq

As gems e suas respectivas versões podem ser visualizadas no Gemfile.lock

## 2. Autenticação
Para usar os serviços do crawler é preciso primeiro receber um token de autenticação JWT. Para isso, pode-se:

### Cadastrar um usuário
**Endpoint: POST /user/signup**

O usuário poderá se cadastrar, fornecendo um **nome de usuário** e uma **senha** em formato **JSON** no corpo da requisição.

Se aquele nome de usuário já estiver sido cadastrado por outrém, um erro com o **status 400(Bad Request)** será retornado.

![Screenshot from 2022-02-27 19-36-09](https://user-images.githubusercontent.com/53349364/155903014-a7229ea6-7835-46b7-955d-1d0e3472e3cc.png)
*Exemplo da requisição via Postman*

### Realizar login
**Endpoint: POST /user/login**

Da mesma forma, se o usuário já possuir um cadastro, poderá requisitar o token pelo endpoint de login.

O endpoint de login recebe os mesmo parâmetros de entrada que o de cadastro, ou seja, **nome de usuário** e **senha**.

<hr>

### Utilizando o token

Cumprido um dos passos acima, o usuário poderá utilizar o token, definindo-o no **cabeçalho de autorização** das requisições que o exigirem.

![Screenshot from 2022-02-27 19-47-15](https://user-images.githubusercontent.com/53349364/155903194-16e881db-1b5b-45aa-9e7f-5051d30c39c0.png)

*Definindo o token no cabeçalho da requisição no Postman*

**Observação:** os tokens JWT são gerados dinamicamente e são válidos por **10 minutos**.

## 3. Buscando frases
**Endpoint: GET /quotes/*[tag]***

O usuário poderá obter todas as frases a partir de determinada **tag** ou categoria, disponível no site.

![Screenshot from 2022-02-27 19-50-24](https://user-images.githubusercontent.com/53349364/155903269-65b46295-1e3a-4020-aa64-05fc7600b91a.png)

*Exemplo de consulta de frases por tag*

Serão retornadas do crawler todas as frases que possuam a tag escolhida em sua lista de tags.

- Se não houver nenhuma frase para uma determinada consulta, a resposta da API será **200 (OK)**, porém o array _quotes_ será retornado vazio 
- A primeira consulta **à uma tag** fará com que o crawler faça uma busca pelo site, implicando numa requisição que levará em torno de 3 segundos.
- Se a **tag** já houver sido buscada pelo menos uma vez no período de uma semana, serão retornadas as frases guardadas em **cache**, levando em torno de 20 milissegundos. 
- Uma frase de um autor será guardada em cache apenas uma vez, buscas no site que passarem pela mesma frase não a armazenarão novamente.

**Redis/Sidekiq**
Instalado e configurado serviço em background, caso queira implementar no futuro.
