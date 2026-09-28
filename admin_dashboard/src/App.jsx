import React, { useState, useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate, useLocation } from 'react-router-dom';
import Header from './components/Header';
import Sidebar from './components/Sidebar';
import AdminLogin from './pages/AdminLogin';
import Dashboard from './pages/Dashboard';
import ReviewQueue from './pages/ReviewQueue';
import ReviewCase from './pages/ReviewCase';
import UnreachedStudents from './pages/UnreachedStudents';
import VerificationLayer from './pages/VerificationLayer';

function AdminLayout({ children, user, onLogout }) {
  const [pendingCount, setPendingCount] = useState(1);

  return (
    <div className="flex min-h-screen bg-slate-50 font-sans">
      <Sidebar pendingCount={pendingCount} />
      <div className="flex-1 flex flex-col min-w-0">
        <Header user={user} onLogout={onLogout} />
        <main className="flex-1 overflow-y-auto">
          {children}
        </main>
      </div>
    </div>
  );
}

export default function App() {
  const [currentUser, setCurrentUser] = useState(() => {
    const saved = localStorage.getItem('jago_officer_user');
    return saved ? JSON.parse(saved) : { role: 'officer', full_name: 'Dr. Ananya Sharma' };
  });

  const handleLoginSuccess = (user) => {
    setCurrentUser(user);
  };

  const handleLogout = () => {
    localStorage.removeItem('jago_officer_token');
    localStorage.removeItem('jago_officer_user');
    setCurrentUser(null);
  };

  return (
    <Router>
      <Routes>
        <Route 
          path="/login" 
          element={
            currentUser ? (
              <Navigate to="/admin/dashboard" replace />
            ) : (
              <AdminLogin onLoginSuccess={handleLoginSuccess} />
            )
          } 
        />
        <Route
          path="/admin/dashboard"
          element={
            <AdminLayout user={currentUser} onLogout={handleLogout}>
              <Dashboard />
            </AdminLayout>
          }
        />
        <Route
          path="/admin/reviews"
          element={
            <AdminLayout user={currentUser} onLogout={handleLogout}>
              <ReviewQueue />
            </AdminLayout>
          }
        />
        <Route
          path="/admin/reviews/:caseId"
          element={
            <AdminLayout user={currentUser} onLogout={handleLogout}>
              <ReviewCase />
            </AdminLayout>
          }
        />
        <Route
          path="/admin/unreached"
          element={
            <AdminLayout user={currentUser} onLogout={handleLogout}>
              <UnreachedStudents />
            </AdminLayout>
          }
        />
        <Route
          path="/admin/verification"
          element={
            <AdminLayout user={currentUser} onLogout={handleLogout}>
              <VerificationLayer />
            </AdminLayout>
          }
        />
        {/* Default route */}
        <Route path="*" element={<Navigate to="/admin/dashboard" replace />} />
      </Routes>
    </Router>
  );
}
