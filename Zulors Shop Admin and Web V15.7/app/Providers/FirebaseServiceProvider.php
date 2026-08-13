<?php

namespace App\Providers;

use Kreait\Firebase\Auth;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging;
use Illuminate\Support\ServiceProvider;

class FirebaseServiceProvider extends ServiceProvider
{
    /**
     * Register services.
     *
     * @return void
     */
    public function register(): void
    {
        $this->app->singleton(Factory::class, function ($app) {
            $firebaseConfig = getWebConfig('push_notification_key');
            if (!$this->hasUsableFirebaseConfig($firebaseConfig)) {
                return null;
            }

            $serviceAccount = $firebaseConfig;
            if (is_string($firebaseConfig) && str_starts_with(trim($firebaseConfig), '{')) {
                $serviceAccount = json_decode($firebaseConfig, true);
            }

            return (new Factory)->withServiceAccount($serviceAccount);
        });

        $this->app->singleton(Auth::class, function ($app) {
            $factory = $app->make(Factory::class);
            return $factory ? $factory->createAuth() : null;
        });

        $this->app->singleton(Messaging::class, function ($app) {
            $factory = $app->make(Factory::class);
            return $factory ? $factory->createMessaging() : null;
        });

        // Optionally, you can bind it to a simpler alias
        $this->app->alias(Messaging::class, 'firebase.messaging');
    }

    /**
     * Bootstrap services.
     *
     * @return void
     */
    public function boot()
    {
        //
    }

    private function hasUsableFirebaseConfig(mixed $firebaseConfig): bool
    {
        if (!is_string($firebaseConfig)) {
            return is_array($firebaseConfig) && !empty($firebaseConfig);
        }

        $firebaseConfig = trim($firebaseConfig);
        if ($firebaseConfig === '' || $firebaseConfig === 'Put your firebase server key here.') {
            return false;
        }

        if (str_starts_with($firebaseConfig, '{')) {
            return json_validate($firebaseConfig);
        }

        return is_file($firebaseConfig);
    }
}
