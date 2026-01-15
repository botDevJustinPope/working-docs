import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { BaseService } from './base.service';
import { AareasGetSurfaceListReturnDTO } from '../models/Aareas/aareasGetSurfaceListReturnDTO';
import { AareasGetProductPackageListReturnDTO } from '../models/Aareas/aareasPackagesDTOs';
import { AareasGetSceneRenderReturnDTO, AareasSurfaceProductPairDTO } from '../models/Aareas/aareasGetImageDTOs';

@Injectable({
  providedIn: 'root',
})
/**
 * AareasService is a service that houses the methods for interacting with the Aareas API.
 */
export class AareasService extends BaseService {
  constructor(client: HttpClient) {
    super(client);
    this.rootUrl = 'https://api.aareas.com/api';
  }

  /**
   * getSurfaceList method retrieves a list of surfaces from the aareas API.
   * @returns An observable of AareasGetSurfaceListReturnDTO, which contains a list of surfaces with their scene IDs, room names, and renderable surface lists.
   */
  public async getSurfaceList(): Promise<AareasGetSurfaceListReturnDTO> {
    return await this.get<AareasGetSurfaceListReturnDTO>(
      'SceneSurface/GetClientSurfaceList/b73ce491-bc27-42a7-ad85-6463eca43bfd'
    );
  }

  /**
   * getProductPackageList method retrieves a list of packages configured with Aareas.
   * @param onlyDigitalAssets a boolean flag indicating whether to only return surface product pairs that are valid digital assets
   * @returns An observable of AareasGetProductPackageListReturnDTO, which contains a list of packages with their names, GUIDs, and associated product GUIDs.
   */
  public async getProductPackageList(onlyDigitalAssets: boolean = false): Promise<AareasGetProductPackageListReturnDTO> {
    return await this.get<AareasGetProductPackageListReturnDTO>(
      `ClientProduct/GetClientProductPackageList/${onlyDigitalAssets}/veodesignstudiostaging/44102854-ef6a-467e-8ea1-b574573bdbd3`
    );
  }

  /**
   * getPackageByGUID method retrieves a specific package by its GUID.
   * @param packageGUID GUID of the package to retrieve
   * @returns An observable of AareasGetProductPackageListReturnDTO, which contains the details of the package with its name, GUID, and associated product GUIDs.
   */
  public async getPackageByGUID(packageGUID: string): Promise<AareasGetProductPackageListReturnDTO> {
    return await this.get<AareasGetProductPackageListReturnDTO>(
      `ClientProduct/GetClientPackage/${packageGUID}/veodesignstudiostaging/44102854-ef6a-467e-8ea1-b574573bdbd3`
    );
  }

  /**
   * getSceneRender method retrieves the stream URL for a rendered scene image based on the provided parameters.
   * @param sceneId - ID of the scene to render
   * @param room - Name of the room to render
   * @param applications - Array of AareasSurfaceProductPairDTO representing surface-product pairs to apply in the render
   * @param packages - Array of package GUIDs to include in the render
   * @returns A promise that resolves to AareasGetSceneRenderReturnDTO containing the rendered scene image data
   */
  public async getSceneRender(
    sceneId: number,
    room: string,
    applications: Array<AareasSurfaceProductPairDTO> = [],
    packages: Array<string> | null = null
  ) : Promise<AareasGetSceneRenderReturnDTO> {
    let parms: { [key: string]: any } = {};
    parms['sceneId'] = sceneId;
    parms['room'] = room;
    parms['size'] = 2560;
    parms['userId'] = 'justinpo@buildontechnologies.com';
    parms['client'] = 'BuildOn';
    parms['builder'] = 'Angular-Test-Project';
    parms['project'] = 'demo';
    parms['unit'] = '1234 Home Sweet Home';
    parms['applications'] = applications;
    if (packages) {
      parms['packages'] = packages;
    }
    return await this.get<AareasGetSceneRenderReturnDTO>(
      '/Image/GetImage/v2/Buildon',
      parms
    );
  }
}
