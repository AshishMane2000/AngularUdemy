import { Component } from '@angular/core';
import { Recipe } from '../recipe.model';
@Component({
  selector: 'app-recipe-list',
  templateUrl: './recipe-list.component.html',
  styleUrl: './recipe-list.component.css'
})
export class RecipeListComponent {
Recipes:Recipe[]=[
  new Recipe("a",'b','c'),
  new Recipe("a",'b','c')
]
}
