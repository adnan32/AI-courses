
//Task 2 - Odd-Even Sort using CUDA Adnan Altukleh & Abdulkarim Dawalibi

#include <vector>
#include <algorithm>
#include <iostream>
#include <chrono>
#include <cuda_runtime.h>
#define THREADS 1024



__global__ void OES_kernel(int* data, int size, int phase) {
    int index = blockIdx.x * blockDim.x + threadIdx.x;// Get the index of the current element to process
    int thread_offset = index * 2 + phase;
    for (int j = thread_offset;  j < size-1; j += THREADS *2) {
        if (data[j] > data[j + 1]) {
            int temp = data[j];
            data[j] = data[j + 1];
            data[j + 1] = temp;
        }
    }
    
}





void oddevensort(int* x, int size) {
    // Allocate GPU memory
    int *x_d;
    cudaMalloc((void**) &x_d, size*sizeof(int));
    // Copy data to GPU memory
    cudaMemcpy(x_d, x, size*sizeof(int), cudaMemcpyHostToDevice);
    // Perform computation on GPU
    int numThreadsPerBlock = THREADS; // A common choice for the number of threads per block
    int numBlocks = 10;
    for (int i=1; i<=size; i++) {
        OES_kernel<<<numBlocks,numThreadsPerBlock>>>(x_d,size,i%2);
        // Wait for the GPU to finish
    }
    cudaDeviceSynchronize();
    // Copy data from GPU memory
    cudaMemcpy(x, x_d, size*sizeof(int), cudaMemcpyDeviceToHost);
    // Deallocate GPU memory
    cudaFree(x_d);
}

void print_sort_status(std::vector<int> numbers)
{
    std::cout << "The input is sorted?: " << (std::is_sorted(numbers.begin(), numbers.end()) == 0 ? "False" : "True") << std::endl;
}

int main(){
    constexpr unsigned int size = 100000; // Number of elements in the input
    // Initialize a vector called numbers with integers of value 0 and size of size above
    std::vector<int> numbers(size);

    // Populate our vector with (pseudo)random numbers
    srand(static_cast<unsigned int>(time(0))); // Seed the random number generator
    generate(numbers.begin(), numbers.end(), rand);
    auto start = std::chrono::steady_clock::now();  // Start the timer
    // Sort using CUDA
    oddevensort(numbers.data(), numbers.size());
    // check if the vector is sorted
    auto end = std::chrono::steady_clock::now();  // End the timer
    print_sort_status(numbers);
    std::cout << "Elapsed time =  " << std::chrono::duration<double>(end - start).count() << " sec\n"; // Print the elapsed time
    return 0;
}