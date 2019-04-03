const N_FIB = 27

var fib = newSeq[int](N_FIB)

fib[0]=1
fib[1]=1

for i in countup(2,N_FIB-1):
  fib[i]=fib[i-2]+fib[i-1]

echo fib
