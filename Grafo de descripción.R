###----ANÁLISIS DE LA DESCRIPIÓN DE LA CUENTA----###

#Creo y limpio el corpus para el dataset completo y los dos grupos
corpus_datos_descr <- Corpus(VectorSource(dataset$profile_description))
corpus_datos_descr <- limpiarCorpus(corpus_datos_descr)
corpus_antik_descr <- Corpus(VectorSource(antik$profile_description))
corpus_antik_descr <- limpiarCorpus(corpus_antik_descr)
corpus_sinantik_descr <- Corpus(VectorSource(sin_antik$profile_description))
corpus_sinantik_descr <- limpiarCorpus(corpus_sinantik_descr)

#Creo las columnas con el texto limpio para los tres conjuntos
texto_limpio <- data.frame(tweet = sapply(corpus_datos_descr, as.character), stringsAsFactors = FALSE)
dataset$descripcion_limpia <- texto_limpio$tweet

texto_limpio <- data.frame(tweet = sapply(corpus_antik_descr, as.character), stringsAsFactors = FALSE)
antik$descripcion_limpia <- texto_limpio$tweet

texto_limpio <- data.frame(tweet = sapply(corpus_sinantik_descr, as.character), stringsAsFactors = FALSE)
sin_antik$descripcion_limpia <- texto_limpio$tweet

#Creo y ordeno la Term Document Matrix para los tres grupos
tdm_datos_descr <- TermDocumentMatrix(corpus_datos_descr,control = list(wordLengths = c(1, 20)))
tdm_datos_descr <- removeSparseTerms(tdm_datos_descr, 0.99)

tdm_antik_descr <- TermDocumentMatrix(corpus_antik_descr,control = list(wordLengths = c(1, 20)))
tdm_antik_descr <- removeSparseTerms(tdm_antik_descr, 0.99)

tdm_sinantik_descr <- TermDocumentMatrix(corpus_sinantik_descr,control = list(wordLengths = c(1, 20)))
tdm_sinantik_descr <- removeSparseTerms(tdm_sinantik_descr, 0.99)

#(freq.terms <- findFreqTerms(tdm_datos, lowfreq = 1000))
#term.freq <- rollup(tdm_datos, 2, na.rm=TRUE, FUN = sum)

#Creo una matrix
tdm_matrix <- as.matrix(tdm_datos_descr)
tdm_matrix_antik_descr <- as.matrix(tdm_antik_descr)
tdm_matrix_sinantik_descr <- as.matrix(tdm_sinantik_descr)

#Convierto la matriz en una matriz de adyacencia
tdm_matrix[tdm_matrix>=1] <- 1
tdm_matrix_antik_descr[tdm_matrix_antik_descr>=1] <- 1
tdm_matrix_sinantik_descr[tdm_matrix_sinantik_descr>=1] <- 1

#Convierto la matriz de adyacencia en una matriz de términos
term_matrix <- tdm_matrix %*% t(tdm_matrix)
term_matrix_antik_descr <- tdm_matrix_antik_descr %*% t(tdm_matrix_antik_descr)
term_matrix_sinantik_descr <- tdm_matrix_sinantik_descr %*% t(tdm_matrix_sinantik_descr)

#Limpio los objetos y junto la basura
rm("tdm_matrix", "tdm_matrix_antik_descr", "tdm_matrix_sinantik_descr")
gc()

#Armo un grafo (saco bucles, pongo etiquetas y grados)
grafo_descr <- graph.adjacency(term_matrix, weighted=T, mode = "undirected")
set.seed(999)
grafo_descr <- simplify(grafo_descr, remove.loops = T, remove.multiple = T, edge.attr.comb=list(Weight="sum","ignore"))
V(grafo_descr)$label <- V(grafo_descr)$name
V(grafo_descr)$degree <- degree(grafo_descr)
V(grafo_descr)$label <- ifelse(degree(grafo_descr) > 10,V(grafo_descr)$label,NA)
V(grafo_descr)$label.cex <- degree(grafo_descr) / max(degree(grafo_descr)) + 1

#Ploteo el grafo de las conexiones entre descripciones
png("grafo_descr_antik.png", width = 1000, height = 1000)
dev.off()

#grafo_comunidad <- cluster_edge_betweenness(as.undirected(grafo),merges=T)
#grafo <- delete.edges(grafo, which(E(grafo)$weight <=300))
plot(grafo_descr, vertex.size = sqrt(degree(grafo_descr)), 
     edge.width = 0.1, margin = c(0,0,0,0),main = "Descripciones de cuentas con participación previa",
     layout = layout_on_sphere(grafo_descr), edge.width = 0.5, rescale = T, vertex.label.color = "black",
     vertex.frame.color = "red")