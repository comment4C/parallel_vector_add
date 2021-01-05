#include<stdio.h>
#include<math.h>

__global__ void parallel_vector_add(int* d_a, int* d_b, int* d_c, int* d_n) {
    int i = (blockIdx.x * blockDim.x) + threadIdx.x;
    if(i < *d_n) {
        printf("I am about to compute c[%d].\n", i);
        d_c[i] = d_a[i] + d_b[i];
    }else {
        printf("I am therad #%d, and doing nothing.\n", i);
    }
}

int main() {
    int n;

    scanf("%d", &n);

    int h_a[n];
    int h_b[n];
    for(int i=0; i<n; i++) {
        h_a[i] = i;
        h_b[i] = n-i;
    }

    int h_c[n];

    int* d_a, *d_b, *d_c, *d_n;
    cudaMalloc((void **) &d_a, n*sizeof(int));
    cudaMalloc((void **) &d_b, n*sizeof(int));
    cudaMalloc((void **) &d_c, n*sizeof(int));
    cudaMalloc((void **) &d_n, sizeof(int));

    cudaMemcpy(d_a, &h_a, n*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, &h_b, n*sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_n, &n, sizeof(int), cudaMemcpyHostToDevice);

    int block = ceil(n/10.0);

    parallel_vector_add<<<block, 10>>>(d_a, d_b, d_c, d_n);
    cudaDeviceSynchronize();

    cudaMemcpy(&h_c, d_c, n*sizeof(int), cudaMemcpyDeviceToHost);
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    for(int i = 0; i < n; i++)
        printf("%d ", h_c[i]);
}