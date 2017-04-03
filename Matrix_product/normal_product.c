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

void mult_matrix(int m1[][m_size],int m2[][m_size],int r[][m_size],int n)
{
    for(int i=0;i<n;i++)
    {
        for(int j=0;j<n;j++)
        {
            r[i][j]=0;
            for(int k=0;k<n;k++)
            {
                r[i][j]+=m1[i][k]*m2[k][j];
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

    mult_matrix(m1,m2,r,m_size);

	return 0;
}
