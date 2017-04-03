#include <stdio.h>


const int m_size = 600;


void fill_matrix(int m[][m_size],int n,int elem)
{
    for(int i=0;i<n;i++)
    {
        for(int j=0;j<n;j++)
        {
            m[i][j]=elem;
        }
    }
}

void block_mult(int m1[][m_size],int m2[][m_size],int r[][m_size],int n,int block_num)
{
    int block_size = n/block_num;

    for(int ii=0;ii<block_num;ii++)
    {
        for(int jj=0;jj<block_num;jj++)
        {
            for(int kk=0;kk<block_num;kk++)
            {
                for(int i=ii*block_size;i<(ii+1)*block_size;i++)
                {
                    for(int j=jj*block_size;j<(jj+1)*block_size;j++)
                    {
                        for(int k=kk*block_size;k<(kk+1)*block_size;k++)
                        {
                            r[i][j] += m1[i][k]*m2[k][j];
                        }
                    }
                }
            }
        }
    }
}

int main()
{
	
	int m1[m_size][m_size];
    fill_matrix(m1,m_size,2);
    int m2[m_size][m_size];
    fill_matrix(m2,m_size,2);
    int r[m_size][m_size];
    fill_matrix(r,m_size,0);

    block_mult(m1,m2,r,m_size,3);

	return 0;
}
