import { CommonModule } from '@angular/common';
import { HttpClientModule } from '@angular/common/http';
import { Component, OnInit } from '@angular/core';
import { UsersListDTO } from '../../models/UserListDTO';
import { UsersService } from '../../services/users.service';
import { UserDTO } from '../../models/UserDTO';
import { response } from 'express';
import { FormsModule } from '@angular/forms';

@Component({
  selector: 'app-admin',
  standalone: true,
  imports: [CommonModule, HttpClientModule, FormsModule],
  templateUrl: './admin.component.html',
  styleUrl: './admin.component.css',
})
export class AdminComponent implements OnInit {
  users: UsersListDTO[] = [];
  selectedUser: UserDTO | null = null;
  selectedUserId: number | null = null;
  message: string | null = null;
  errorMessage: string | null = null;
  isEditMode: boolean = false;

  constructor(private usersService: UsersService) {}

  ngOnInit(): void {
    this.loadUsers();
  }

  loadUsers(): void {
    this.usersService.getUsers().subscribe(
      (data) => {
        this.users = data;
      },
      (error) => {
        console.error('Failed to get users', error);
      }
    );
  }

  viewUser(userId: number): void {
    if (this.selectedUserId === userId && !this.isEditMode) {
      // Toggle display off if the user is already selected and not in edit mode
      this.selectedUser = null;
      this.selectedUserId = null;
    } else {
      this.isEditMode = false;
      this.usersService.getUserById(userId).subscribe(
        (data) => {
          this.selectedUser = data;
          this.selectedUserId = userId;
        },
        (error) => {
          console.error(`Failed to get details for user ID ${userId}`, error);
        }
      );
    }
  }

  editUserForm(userId: number): void {
    this.isEditMode = true;
    this.usersService.getUserById(userId).subscribe(
      (data) => {
        this.selectedUser = data;
        this.selectedUserId = userId;
      },
      (error) => {
        console.error(`Failed to get details for user ID ${userId}`, error);
      }
    );
  }

  editUser(): void {
    if (this.selectedUser) {
      this.usersService.updateUser(this.selectedUser).subscribe(
        (response) => {
          this.message = response;
          this.errorMessage = null;
          this.loadUsers();
          this.closeEditForm();
        },
        (error) => {
          this.errorMessage = error.error;
          console.error(
            `Failed to update user ID ${this.selectedUser?.userId}`,
            error
          );
        }
      );
    }
  }

  closeEditForm(): void {
    this.isEditMode = false;
    this.errorMessage = null;
  }

  deleteUser(userId: number): void {
    if (confirm('Are you sure you want to delete this user?')) {
      this.usersService.deleteUser(userId).subscribe(
        (response) => {
          this.message = response;
          this.errorMessage = null;
          this.loadUsers();
        },
        (error) => {
          console.error(`Failed to delete user ID ${userId}`, error);
        }
      );
    }
  }

  closeUserDetails(): void {
    this.selectedUser = null;
    this.selectedUserId = null;
    this.errorMessage = null;
    this.message = null;
  }

  clearMessages(): void {
    this.message = null;
    this.errorMessage = null;
  }
}
