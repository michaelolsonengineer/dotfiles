# web_search from terminal

function web_search() {
  local site=$1
  shift
  # join arguments passed with '+', then append to search engine URL
  local siteSearchParams=$(joins + $@)

  # define search engine URLS
  declare -A urls
  urls[google]="https://www.google.com/search?q="
  urls[bing]="https://www.bing.com/search?q="
  urls[yahoo]="https://search.yahoo.com/search?p="
  urls[duckduckgo]="https://www.duckduckgo.com/?q="
  urls[startpage]="https://www.startpage.com/do/search?q="
  urls[yandex]="https://yandex.ru/yandsearch?text="
  urls[github]="https://github.com/search?q="
  urls[baidu]="https://www.baidu.com/s?wd="
  urls[ecosia]="https://www.ecosia.org/search?q="
  urls[goodreads]="https://www.goodreads.com/search?q="
  urls[stackoverflow]="https://stackoverflow.com/search?q="
  urls[wikipedia]="https://en.wikipedia.org/w/index.php?search="
  urls[dictionary]="https://www.thefreedictionary.com/"

  # check whether the search engine is supported
  if [ -z "$urls[$site]" ]; then
    echo "Search engine $site not supported."
    return 1
  fi

  # search or go to main page depending on number of arguments passed
  url="${urls[$site]}$siteSearchParams"

  echo $url
  open_command "$url"
}

alias bing='web_search bing'
alias google='web_search google'
alias yahoo='web_search yahoo'
alias ddg='web_search duckduckgo'
alias sp='web_search startpage'
alias yandex='web_search yandex'
alias github='web_search github'
alias baidu='web_search baidu'
alias ecosia='web_search ecosia'
alias goodreads='web_search goodreads'
alias stackoverflow='web_search stackoverflow'
alias wikipedia='web_search wikipedia' # technically handled by duckduckgo
alias dictionary='web_search dictionary'

#add your own !bang searches here
alias wiki='web_search duckduckgo \!w'
alias news='web_search duckduckgo \!n'
alias youtube='web_search duckduckgo \!yt'
alias map='web_search duckduckgo \!m'
alias image='web_search duckduckgo \!i'
alias ducky='web_search duckduckgo \!'
alias define='web_search dictionary'
