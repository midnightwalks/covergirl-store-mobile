from locust import HttpUser, task, between

class MakeupUser(HttpUser):
    wait_time = between(1, 3)  # waktu tunggu antar request (detik)

    @task(1)
    def get_covergirl_products(self):
        self.client.get("/api/v1/products.json?brand=covergirl")