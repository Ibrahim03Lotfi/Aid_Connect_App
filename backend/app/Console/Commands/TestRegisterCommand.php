<?php

namespace App\Console\Commands;

use App\Http\Controllers\Api\AuthController;
use Illuminate\Console\Command;
use Illuminate\Http\Request;

class TestRegisterCommand extends Command
{
    /**
     * The name and signature of console command.
     *
     * @var string
     */
    protected $signature = 'test:register';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Test the registration endpoint';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        $this->info('Testing registration endpoint...');
        
        try {
            $request = Request::create('/api/auth/register', 'POST', [
                'name' => 'Test User',
                'email' => 'test' . time() . '@example.com',
                'phone' => '01234567890',
                'password' => 'password123'
            ]);
            
            $controller = new AuthController();
            $response = $controller->register($request);
            
            $this->info('Status Code: ' . $response->getStatusCode());
            $this->info('Response: ' . $response->getContent());
            
        } catch (\Exception $e) {
            $this->error('Error: ' . $e->getMessage());
            $this->error('File: ' . $e->getFile());
            $this->error('Line: ' . $e->getLine());
        }
    }
}
