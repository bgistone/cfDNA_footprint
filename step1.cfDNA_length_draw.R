args<-commandArgs()
sam=args[4]
print(args)
d=read.table(paste(sam,"cfDNA_length_distribution.txt",sep="."),header=F)
dd=d[100:1000,]
ddsum=sum(dd[,2])
ddratio=dd[,2] / ddsum * 100
pdf(file=paste(sam,"cfDNA_length_distribution.pdf",sep="."))
plot(x=dd[,1], y=ddratio, type='l', lwd = 3, xaxt='n', ylab="Percent of fragments",xlab="Fragment length")
axis(1,at=seq(40,500,10))
xx=seq(100,300,10)
abline(v=xx,lty=3)
legend("topright", legend=c(sam) )
dev.off()


