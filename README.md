# Quotes Crawler

Crawler que busca frases no website <a href="http://quotes.toscrape.com/">Quotes to Scrape</a> a partir de determinada categoria.

## 1. Primeiros passos

Este projeto foi desenvolvido usando as seguintes tecnologias com as seguintes versões:

- Ruby 2.7.0p0
- Rails 5.2.6
- MongoDB 3.6.8

As gems e suas respectivas versões podem ser visualizadas no Gemfile.lock

Todas as requisições descritas nesse manual foram feitas usando o Postman. Elas estão desponíveis no <a href="https://github.com/RamonGiovane/quotes_crawler/blob/main/postman_collection.json">arquivo de importação
aqui</a> (use "Salvar link como...". Também presente ao fazer clone do repositório).


## 2. Autenticação
Para usar os serviços do crawler é preciso primeiro receber um token de autenticação JWT. Para isso, pode-se:

### Cadastrar um usuário
**Endpoint: POST /user/signup**

O usuário poderá se cadastrar, fornecendo um **nome de usuário** e uma **senha** em formato **JSON** no corpo da requisição.

Se aquele nome de usuário já estiver sido cadastrado por outrém, um erro com o **status 400(Bad Request)** será retornado.

![image](https://user-images.githubusercontent.com/40267373/121582193-1b80b880-ca05-11eb-885d-7f644ba786da.png)

*Exemplo da requisição via Postman*

### Realizar login
**Endpoint: POST /user/login**

Da mesma forma, se o usuário já possuir um cadastro, poderá requisitar o token pelo endpoint de login.

O endpoint de login recebe os mesmo parâmetros de entrada que o de cadastro, ou seja, **nome de usuário** e **senha**.

<hr>

### Utilizando o token

Cumprido um dos passos acima, o usuário poderá utilizar o token, definindo-o no **cabeçalho de autorização** das requisições que o exigirem.

![Screenshot from 2022-02-27 19-36-09](https://user-images.githubusercontent.com/53349364/155903014-a7229ea6-7835-46b7-955d-1d0e3472e3cc.png)

*Definindo o token no cabeçalho da requisição no Postman*

**Observação:** os tokens JWT são gerados dinamicamente e são válidos por **10 minutos**.

## 3. Buscando frases
**Endpoint: GET /quotes/*[tag]***

O usuário poderá obter todas as frases a partir de determinada **tag** ou categoria, disponível no site.

![image](https://user-images.githubusercontent.com/40267373/121584608-09544980-ca08-11eb-9ad8-cbdb4b25ac83.png)

*Exemplo de consulta de frases por tag*

Serão retornadas do crawler todas as frases que possuam a tag escolhida em sua lista de tags.

- Se não houver nenhuma frase para uma determinada consulta, a resposta da API será **200 (OK)**, porém o array _quotes_ será retornado vazio 
- A primeira consulta **à uma tag** fará com que o crawler faça uma busca pelo site, implicando numa requisição que levará em torno de 3 segundos.
- Se a **tag** já houver sido buscada pelo menos uma vez no período de uma semana, serão retornadas as frases guardadas em **cache**, levando em torno de 20 milissegundos. 
- Uma frase de um autor será guardada em cache apenas uma vez, buscas no site que passarem pela mesma frase não a armazenarão novamente.

## 4. Limpando o cache
O cache para determinada tag é válido por uma semana. Se isso não for interessante para o usuário, o mesmo poderá usar as seguintes operações:

### Invalidando o cache de uma tag/Resetar uma tag
**Endpoint:POST /quotes/*[tag]*/reset**

Resetar uma tag fará com que ela seja excluída da lista de tags pesquisadas no cache, assim fazendo com que a próxima requisição por ela na API
busque diretamente do site, ignorando o cache, ou seja, obrigando o crawler a rescanear o site na próxima consulta. 

**Observação:** Isso não faz com que as frases em cache sejam apagadas, apenas força que seja realizada uma nova busca. Se o site por exemplo remover 
uma frase, o cache ainda conterá ela.

![image](https://user-images.githubusercontent.com/40267373/121594084-fc892300-ca12-11eb-8918-59b14f1d1b30.png)

*Limpando uma tag no Postman*

## Limpar frases de uma tag
**Endpoint: POST /quotes/*[tag]*/clean**

Exclui todas as frases de uma tag do cache e a reseta (veja o item anterior). 

**Observação:** Essa opção pode não ser tão interessante porque há frases com multiplas tags. Por exemplo, suponha as tag 'love' e 'inspirational'.
Se o cache for limpo passando apenas a tag 'inspirational', todas as frases contendo 'love' e 'inspirational' serão apagadas. Então posteriores consultas com
'love' vindas do cache serão incompletas.

## Limpar todo o cache
**Endpoint: POST /quotes/clean**

Limpa todas as frases de todas as tags e as reseta.

![image](https://user-images.githubusercontent.com/40267373/121599697-d0bd6b80-ca19-11eb-9636-801975487d30.png)

*Limpando todo o cache usando Postman*
