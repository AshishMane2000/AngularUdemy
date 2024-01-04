import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppComponent } from './app.component';
import { appHeader } from './app/header/header.component';
import { RecipesComponent } from './app/recipes/recipes.component';
import { RecipeDetailComponent } from './app/recipes/recipe-detail/recipe-detail.component';
import { RecipeListComponent } from './app/recipes/recipe-list/recipe-list.component';
import { RecipeItemComponent } from './app/recipes/recipe-list/recipe-item/recipe-item.component';
import { ShoppingListComponent } from './app/shopping-list/shopping-list.component';
import { ShoppingEditComponent } from './app/shopping-list/shopping-edit/shopping-edit.component';

@NgModule({
  declarations: [
    AppComponent,appHeader, RecipesComponent, RecipeDetailComponent, RecipeListComponent, RecipeItemComponent, ShoppingListComponent, ShoppingEditComponent
  ],
  imports: [
    BrowserModule
  ],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
