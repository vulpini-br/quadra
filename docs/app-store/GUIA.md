# Como publicar o Quadra na Mac App Store

> **Como a versão da loja move as janelas.** Todo app novo na Mac App Store roda no sandbox, e no
> sandbox o macOS não deixa um app usar a Acessibilidade nos outros apps. Por isso a versão da loja
> lê onde estão as janelas pela lista de janelas do macOS e as move pelo Atalho **"Quadra"** do app
> Atalhos, que ela roda em segundo plano pelo Shortcuts Events. O Atalho é gerado por
> `Tools/make-shortcut.py`, assinado com `shortcuts sign` (precisa de internet e do iCloud ligado no
> Mac) e vai dentro do app. Na primeira vez, a janela de boas-vindas pede para adicionar o Atalho e
> autorizar o Quadra a usar o Atalhos. Testado em 19/11/2026: grade, layouts e espaços de trabalho
> funcionam, cada movimento leva cerca de 0,3 segundo. Nessa versão, o espaço de trabalho guarda a
> janela da frente de cada app (sem títulos nem documentos).

O código já está pronto para a App Store. `./build.sh --appstore` gera uma versão própria:

- roda no **sandbox**, o modo isolado que a Apple exige, e move as janelas pelo Atalho do Quadra;
- **não tem** o aviso de atualização, porque a App Store atualiza sozinha;
- **não tem** o link "Apoiar o Quadra", porque a Apple não aceita links para pagamentos fora da loja.

Os textos da página estão em [`textos-en.md`](textos-en.md) e [`textos-pt-BR.md`](textos-pt-BR.md),
e as imagens em [`screenshots/`](screenshots). A política de privacidade é o
[`PRIVACY.md`](../../PRIVACY.md) do repositório.

## 0. Conta de desenvolvedor

A conta do Apple Developer Program é de **pessoa física**, em nome de Alan Michelon (equipe
AE7E7GAZLV). A conversão para a Vulpini Contabilidade Ltda (D-U-N-S 648913307) foi pedida à Apple;
quando sair, o nome do vendedor na loja passa a ser o da empresa, sem perder o app.

## 1. Identificador do app

O identificador da versão da App Store é **`br.com.vulpini.quadra`**. Ele já é o padrão do
`build.sh` e não pode mudar depois que o app estiver na loja. (A versão do GitHub e do Homebrew
continua com o identificador antigo, `io.github.ahrmichelon.quadra`, para quem já usa não precisar
liberar a Acessibilidade de novo. Ninguém vê esse nome.)

## 2. Certificados

No Xcode: **Ajustes → Contas**, escolha a conta da Vulpini, **Gerenciar certificados**, clique em
**+** e crie:

- **Apple Distribution**, que assina o app;
- **Mac Installer Distribution**, que assina o pacote enviado à Apple.

Eles ficam no chaveiro do Mac, e o `build.sh` os encontra sozinho.

## 3. Registrar o app

Em [developer.apple.com/account](https://developer.apple.com/account) → **Certificates, Identifiers & Profiles**
→ **Identifiers** → **+** → **App IDs** → **App**. Descrição "Quadra", **Bundle ID** "Explicit" com o
identificador do passo 1. Não precisa marcar nenhuma capability.

## 4. Perfil de provisionamento

Ainda em **Certificates, Identifiers & Profiles** → **Profiles** → **+** → **Mac App Store Connect**.
Escolha o App ID do passo 3 e o certificado **Apple Distribution**. Baixe o arquivo e salve como
`App/AppStore.provisionprofile` neste projeto. Ele fica só no seu Mac: o git ignora esse arquivo.

## 5. Criar o app no App Store Connect

Em [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → **Apps** → **+** → **Novo app**:

- Plataforma: **macOS**
- Nome: **Quadra – Window Grid** (o nome precisa estar livre na loja; "Macintosh Quadra" foi um
  computador da Apple, por isso o complemento)
- Idioma principal: **Inglês (EUA)**, e depois acrescente **Português (Brasil)**
- Bundle ID: o do passo 1
- SKU: `quadra-mac`

## 6. Preencher a página

- **Textos:** copie de `textos-en.md` e `textos-pt-BR.md`.
- **Imagens:** envie as de `screenshots/` em cada idioma, na ordem 1, 2, 3, 4. Para gerar de novo:
  `./Tools/make-store-screenshots.sh`. Capturas reais do app em uso também são bem-vindas.
- **Privacidade do app:** "Dados não coletados". **URL da política:** a de `textos-en.md`.
- **Categoria:** Produtividade. **Classificação etária:** responda "não" a tudo, o que dá 4+.
- **Preço:** **Grátis**, em todos os países.
- **Comerciante na União Europeia (DSA):** um app grátis de pessoa física pode ser declarado como
  **não comerciante**; aí a loja não mostra endereço nem telefone.

Regras da Apple a lembrar: os textos e as palavras-chave da loja **não podem citar outros apps ou
marcas**, e o app não pode mandar baixar versões de fora da loja.

## 7. Gerar o pacote

Com os certificados e o perfil no lugar:

```bash
./build.sh --appstore
```

O script assina o app e gera o `Quadra.pkg`. Se faltar alguma coisa, ele gera só uma versão de
teste e diz o que falta.

## 8. Enviar à Apple

Instale o app **Transporter** (grátis, na Mac App Store), entre com a conta da Vulpini, arraste o
`Quadra.pkg` e clique em **Entregar**. O pacote aparece no App Store Connect depois de alguns minutos.

## 9. Enviar para revisão

Na página da versão, escolha o build enviado, cole as **notas para a revisão** de `textos-en.md`
(explicam por que o app precisa de Acessibilidade e como testar) e clique em
**Enviar para revisão**. A resposta costuma vir em um a três dias.

## Novas versões

Atualize `CFBundleShortVersionString` e `CFBundleVersion` em `App/Info.plist` (o `CFBundleVersion`
sempre precisa subir), rode `./build.sh --appstore`, envie pelo Transporter e crie a versão nova
no App Store Connect.

## Testar a versão em sandbox antes de enviar

1. Feche o Quadra normal: botão direito no ícone → **Sair do Quadra**. Os dois usam os mesmos
   atalhos de teclado.
2. Gere e abra uma versão de teste (sem os certificados da loja, ela sai assinada para este Mac):
   ```bash
   QUADRA_PROVISIONING_PROFILE=/nenhum ./build.sh --appstore
   open ~/Library/Caches/Quadra/AppStore/Quadra.app
   ```
   (se o projeto não estiver num disco exFAT, o caminho é `build/AppStore/Quadra.app`)
3. Na tela de boas-vindas, clique em **Adicionar Atalho** (e em **Adicionar Atalho** no app
   Atalhos), depois em **Permitir o Quadra** e em **OK**. A tela muda para "O Quadra está pronto".
4. Teste: ⌃⌥G e arrastar na grade, ⌃⌥← e ⌃⌥→ para as metades, ⌃⌥C para o centro, e um espaço de
   trabalho (salvar, tirar a janela do lugar, restaurar).
5. Feche a versão de teste e abra de novo o Quadra normal.
