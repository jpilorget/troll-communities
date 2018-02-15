###---ANÁLISIS DEL TEXTO DEL TWEET---###

#Creo y limpio el corpus para los subsets con y sin participación en "novuelvenmas".
corpus_antik <- Corpus(VectorSource(antik$text))
corpus_antik <- limpiarCorpus(corpus_antik)
corpus_sinantik <- Corpus(VectorSource(sin_antik$text))
corpus_sinantik <- limpiarCorpus(corpus_sinantik)


#Creo las columnas con el texto limpio para ambos conjuntos.
texto_antik <- data.frame(tweet = sapply(corpus_antik, as.character), stringsAsFactors = FALSE)
texto_sinantik <- data.frame(tweet = sapply(corpus_sinantik, as.character), stringsAsFactors = FALSE)

#Agrego los datos a los datasets.
antik$texto_limpio <- texto_antik$tweet
sin_antik$texto_limpio <- texto_sinantik$tweet

#Creo y ordeno la Term Document Matrix
tdm_antik <- TermDocumentMatrix(corpus_antik,control = list(wordLengths = c(1, 20)))
tdm_antik <- removeSparseTerms(tdm_antik, 0.99)

tdm_sinantik <- TermDocumentMatrix(corpus_sinantik,control = list(wordLengths = c(1, 20)))
tdm_sinantik <- removeSparseTerms(tdm_sinantik, 0.99)

#Observo la frecuencia de los términos antiK
term.freq <- rollup(tdm_antik, 2, na.rm=TRUE, FUN = sum)
(freq.terms <- findFreqTerms(tdm_antik, lowfreq = 1000))

#Creo una matriz para cada conjunto
matriz_antik <- as.matrix(tdm_antik)
matriz_sinantik <- as.matrix(tdm_sinantik)

#Convierto la matriz en una matriz de adyacencia
matriz_antik[matriz_antik>=1] <- 1
matriz_sinantik[matriz_sinantik>=1] <- 1

#Convierto la matriz de adyacencia en una matriz de términos
term_antik <- matriz_antik %*% t(matriz_antik)
term_sinantik <- matriz_sinantik %*% t(matriz_sinantik)

#Borro los objetos pesados y limpio la basura
rm("matriz_antik", "matriz_sinantik")
gc()

#Armo un grafo para los tweets antiK
set.seed(123)
grafo_antik <- graph.adjacency(term_antik, weighted=T, mode = "undirected")
grafo_antik <- simplify(grafo_antik, remove.loops = T, remove.multiple = T, edge.attr.comb="sum")
grafo_antik <- delete.edges(grafo_antik, which(E(grafo_antik)$weight <=200))
V(grafo_antik)$degree <- degree(grafo_antik)
V(grafo_antik)$label <- ifelse(degree(grafo_antik) > 10,V(grafo_antik)$name,NA)
V(grafo_antik)$label.cex <- degree(grafo_antik) / max(degree(grafo_antik)) + 1

#Ploteo el grafo de las conexiones entre palabas
png("grafo_palabras_antik.png", width = 2000, height = 2000)
plot(grafo_antik, vertex.size = log(degree(grafo_antik)), 
     edge.width = 0.1, main = "Palabras relevantes de comunidad con participación previa",
     layout = layout_with_fr(grafo_antik), vertex.frame.color = "red", margin = c(0,0,0,0),
     vertex.label.family = "sans", vertex.label.color = "black", rescale = T)
dev.off()

#Armo un grafo para los tweets sin antiK
set.seed(123)
grafo_sinantik <- graph.adjacency(term_sinantik, weighted=T, mode = "undirected")
grafo_sinantik <- simplify(grafo_sinantik, remove.loops = T, remove.multiple = T, 
                           edge.attr.comb="sum")
V(grafo_sinantik)$degree <- degree(grafo_sinantik)
V(grafo_sinantik)$label <- ifelse(degree(grafo_sinantik) > 90,V(grafo_sinantik)$name,NA)
V(grafo_sinantik)$label.cex <- degree(grafo_sinantik) / max(degree(grafo_sinantik)) + 1

#Ploteo el grafo de las conexiones entre palabas
png("grafo_palabras_sinantik.png", width = 1500, height = 1500)
#grafo_sinantik_comunidad <- cluster_edge_betweenness(grafo_sinantik,merges=T)
grafo_sinantik <- delete.edges(grafo_sinantik, which(E(grafo_sinantik)$weight <=200))
plot(grafo_sinantik, vertex.size = log(degree(grafo_sinantik)), margin = c(0,0,0,0),
     edge.width = 0.05, main = "Palabras relevantes de comunidad sin participación previa",
     layout = layout_with_fr(grafo_sinantik), vertex.frame.color = "red", rescale = T,
     vertex.label.family = "sans", vertex.label.color = "black")
dev.off()
