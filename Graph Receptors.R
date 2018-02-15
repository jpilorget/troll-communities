#Construyo el grafo de la comunidad de RTs
dataset$receptor <- paste0(ifelse(is.na(dataset$retweeted_screen_name),"",dataset$retweeted_screen_name),
                           ifelse(is.na(dataset$reply_to_screen_name),"",dataset$reply_to_screen_name))

comunidad <- data.frame(cbind(as.character(antik$screen_name),as.character(antik$receptor)))
comunidad <- filter(comunidad, X2 != "")

chat_graph <- graph.edgelist(as.matrix(comunidad))
set.seed(123)
rt_graph <- simplify(rt_graph, remove.loops = T, remove.multiple = T, edge.attr.comb=list(Weight="sum","ignore"))
V(rt_graph)$label <- V(rt_graph)$name
V(rt_graph)$degree <- degree(rt_graph)
rt_graph_layout <- layout.fruchterman.reingold(rt_graph)
V(rt_graph)$label <- ifelse(degree(rt_graph, mode = "in") > 15,V(rt_graph)$label,NA)
V(rt_graph)$label.cex <- degree(rt_graph, mode = "in") / max(degree(rt_graph, mode = "in"))+ 1
V(rt_graph)$label.color <- rgb(0.2, 0.2, .2, .8)
V(rt_graph)$frame.color <- NA
egam <- (log(V(rt_graph)$degree)+.4) / max(log(V(rt_graph)$degree)+.4)
E(rt_graph)$color <- rgb(.5, .5, 0, egam)
E(rt_graph)$width <- egam
# Ploteo el rt_graph
png("rt_graph_trollsinantik.png", width = 2000, height = 2000)
dev.off()
plot(chat_graph, vertex.label = NA)
plot(rt_graph, edge.arrow.size = 0.1, vertex.size = sqrt(degree(rt_graph, mode = "in")), 
     edge.arrow.width = 0.1, margin = c(0,0,0,0),main = "RTs de comunidad con participación en acciones previas",
     layout = layout_with_kk(rt_graph), edge.width = 0.5, rescale = T, vertex.label.color = "black",
     vertex.label.dist = 1, vertex.frame.color = "red")