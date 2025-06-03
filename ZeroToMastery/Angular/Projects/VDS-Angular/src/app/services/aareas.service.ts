import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { BaseService } from './base.service';
import { AareasGetSurfaceListReturnDTO } from '../models/aareasGetSurfaceListReturnDTO';
import { AareasGetProductPackageListReturnDTO } from '../models/aareasPackagesDTOs';

@Injectable({
  providedIn: 'root'
})
/**
 * AareasService is a service that houses the methods for interacting with the Aareas API.
 */
export class AareasService extends BaseService {

  constructor(client: HttpClient) {
    super(client);
    this.rootUrl = 'https://apirc.aareas.com/api';
   }

/**
 * getSurfaceList method retrieves a list of surfaces from the aareas API.
 * @returns An observable of AareasGetSurfaceListReturnDTO, which contains a list of surfaces with their scene IDs, room names, and renderable surface lists.
 */
   async getSurfaceList() {
    return await this.get<AareasGetSurfaceListReturnDTO>('SceneSurface/GetClientSurfaceList/b73ce491-bc27-42a7-ad85-6463eca43bfd');
   }

   /**
    * getProductPackageList method retrieves a list of packages configured with Aareas.
    * @param onlyDigitalAssets a boolean flag indicating whether to only return surface product pairs that are valid digital assets
    * @returns An observable of AareasGetProductPackageListReturnDTO, which contains a list of packages with their names, GUIDs, and associated product GUIDs.
    */
   async getProductPackageList(onlyDigitalAssets: boolean = false) {
    return await this.get<AareasGetProductPackageListReturnDTO>(`ClientProduct/GetClientProductPackageList/${onlyDigitalAssets}/veodesignstudiostaging/44102854-ef6a-467e-8ea1-b574573bdbd3`)
   }
   
   /**
    * getPackageByGUID method retrieves a specific package by its GUID.
    * @param packageGUID GUID of the package to retrieve
    * @returns An observable of AareasGetProductPackageListReturnDTO, which contains the details of the package with its name, GUID, and associated product GUIDs.
    */
   async getPackageByGUID(packageGUID: string) {
    return await this.get<AareasGetProductPackageListReturnDTO>(`ClientProduct/GetClientPackage/${packageGUID}/veodesignstudiostaging/44102854-ef6a-467e-8ea1-b574573bdbd3`);
   }
}
