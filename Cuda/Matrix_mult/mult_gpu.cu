#include <stdio.h>
#include <stdlib.h>

#define TILE 32
#define THREAD_PER_BLOCK TILE*TILE

__global__
void add_matrix(int* a, int* b, int* c,int n)
{
	int col = blockDim.x*blockIdx.x+ threadIdx.x;
	int row = blockDim.y*blockIdx.y+ threadIdx.y;

	if ( col<n && row<n )
	{
		c[row*n+col] = a[row*n+col] + b[row*n+col];
	}
}

__global__
void mult_matrix(int* a, int* b, int* c,int n)
{
	int col = blockDim.x*blockIdx.x+ threadIdx.x;
	int row = blockDim.y*blockIdx.y+ threadIdx.y;


	if ( col<n && row<n )
	{
		int i;
		c[row*n+col] = 0;

		for(i=0;i<n;i++)
		{
			c[row*n + col] += a[ row*n + i ]*b[ i*n + col ];

		}

	}
}

__global__
void mult_matrix_shared(int* a, int* b, int* c,int n)
{
	__shared__ float sub_a[TILE][TILE];
	__shared__ float sub_b[TILE][TILE];

	int bx = blockIdx.x; int by = blockIdx.y;
	int tx = threadIdx.x; int ty = threadIdx.y;
	
	int Row = by * TILE + ty;
	int Col = bx * TILE + tx;

	int Pvalue = 0;
	
	for (int ph = 0; ph < n/TILE; ++ph) {
	
		sub_a[ty][tx] = a[Row*n + ph*TILE + tx];
		sub_b[ty][tx] = b[(ph*TILE + ty)*n + Col];
		__syncthreads();
		
		for (int k = 0; k < TILE; ++k) {
			Pvalue += sub_a[ty][k] * sub_b[k][tx];
		}
		__syncthreads();
	}
	c[Row*n + Col] = Pvalue;
}

void print_matrix(int* a,int n)
{
	int i,j;
	for(i=0;i<n;i++)
	{
		for(j=0;j<n;j++)
		{
			printf("%d ",a[i*n+j]);
		}
		printf("\n");
	}
}

void fill_mat(int* a,int n)
{
	int i,j;
	for(i=0;i<n;i++)
	{
		for(j=0;j<n;j++)
		{
			a[i*n+j] = rand()%5+1;
		}
	}
}

int main()
{
	int *a,*b,*c;
	int *d_a,*d_b,*d_c;

	int mat_elem = 800;
	int my_size = mat_elem*mat_elem*sizeof(int);

	cudaEvent_t my_start,my_stop;
	cudaEventCreate(&my_start);
	cudaEventCreate(&my_stop);

	a = (int*) malloc(my_size);
	b = (int*) malloc(my_size);
	c = (int*) malloc(my_size);

	fill_mat(a,mat_elem);
	fill_mat(b,mat_elem);
	
	cudaMalloc((void**)&d_a,my_size);
	cudaMalloc((void**)&d_b,my_size);
	cudaMalloc((void**)&d_c,my_size);

	cudaMemcpy(d_a,a,my_size,cudaMemcpyHostToDevice);
	cudaMemcpy(d_b,b,my_size,cudaMemcpyHostToDevice);

	dim3 my_block(THREAD_PER_BLOCK,THREAD_PER_BLOCK);
	dim3 my_grid((mat_elem + THREAD_PER_BLOCK-1)/my_block.x,(mat_elem + THREAD_PER_BLOCK-1)/my_block.y);
	
	//////////////////////ELAPSED TIME ///////////////////////////////
	
	cudaEventRecord(my_start,0);
	//mult_matrix<<<my_grid,my_block>>>(d_a, d_b, d_c,mat_elem);
	mult_matrix_shared<<<my_grid,my_block>>>(d_a, d_b, d_c,mat_elem);
	cudaEventRecord(my_stop,0);
	cudaEventSynchronize(my_stop);
	/////////////////////////////////////////////////////
	
	float elapsed_time;
	cudaEventElapsedTime(&elapsed_time,my_start,my_stop);

	cudaMemcpy(c,d_c,my_size,cudaMemcpyDeviceToHost);
	
	printf("Execution time: %f\n",elapsed_time);
	return 0;
}

