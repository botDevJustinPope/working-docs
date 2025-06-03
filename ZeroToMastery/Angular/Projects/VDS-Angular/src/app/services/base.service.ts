import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../environments/environment';
import { firstValueFrom } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export abstract class BaseService {
    protected rootUrl: string;
    /**
     * BaseService is an abstract class that provides a common base for all services in the application.
     * It sets the root URL for the API and can be extended by other services.
     */
    constructor(protected client: HttpClient) {
        // Set the root URL for the API
        this.rootUrl = environment.apiUrl;
    }

    /**
     * get method is a generic method that allows you to make GET requests to the API.
     * @param endpoint The endpoint to which the GET request will be made.
     */
    async get<T>(endpoint: string, params?: { [key: string]: any }) {
        return await firstValueFrom(this.client.get<T>(`${this.buildURL(endpoint, params)}`));
    }

    /**
     * post method is a generic method that allows you to make POST requests to the API.
     * @param endpoint The endpoint to which the POST request will be made.
     * @param body The body of the POST request.
     */
    async post<T>(endpoint: string, body: any, params?: { [key: string]: any }) {
        return await this.client.post<T>(`${this.buildURL(endpoint, params)}`, body);
    }

    /**
     * put method is a generic method that allows you to make PUT requests to the API.
     * @param endpoint The endpoint to which the PUT request will be made.
     * @param body The body of the PUT request.
    */
    async put<T>(endpoint: string, body: any, params?: { [key: string]: any }) {
        return await this.client.put<T>(`${this.buildURL(endpoint, params)}`, body);
    }

    /**
     * delete method is a generic method that allows you to make DELETE requests to the API.
     * @param endpoint The endpoint to which the DELETE request will be made.
     */
    async delete<T>(endpoint: string, params?: { [key: string]: any }) {
        return await this.client.delete<T>(`${this.buildURL(endpoint, params)}`);
    }

    /**
     * buildURL method constructs a full URL for the API endpoint, optionally with query parameters.
     * @param endpoint The endpoint to which the request will be made.
     * @param params An object containing query parameters to be appended to the URL.
     * @return The full URL for the API endpoint (with query parameters if provided).
     */
    protected buildURL(endpoint: string, params?: { [key: string]: any }): string {
        let url = `${this.rootUrl}/${endpoint}`;
        if (params) {
            const queryParams = new URLSearchParams();
            for (const key in params) {
                if (params.hasOwnProperty(key)) {
                    queryParams.append(key, params[key]);
                }
            }
            url += `?${queryParams.toString()}`;
        }
        return url;
    }

}