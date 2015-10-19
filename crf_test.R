library(CRF)

#the number of nodes
nNodes=7

#the number of states
nStates=7

adj <- matrix(0, nrow=nNodes, ncol=nNodes)
for (i in 1:(nNodes-1))
{
  adj[i,i+1] <- 1
  adj[i+1,i] <- 1
}

crf<-make.crf(adj.matrix = adj,n.states = nStates,n.nodes = nNodes)

feature<-make.features(crf, n.nf = 9, n.ef = 1)

par<-make.par(crf,n.par = 9)

train.crf(crf,)